package middleware

import (
	"time"

	"{{.ProjectModule}}/cmd/lib"
	"{{.ProjectModule}}/tool"

	"gitee.com/krio/erresp"
	"github.com/garyburd/redigo/redis"
	"github.com/gin-gonic/gin"
	limit "github.com/yangxikun/gin-limit-by-key"
	"golang.org/x/time/rate"
)

// 限流方式
type LimitKey int32

const (
	LIMIT_IP          LimitKey = iota + 1 // 仅IP
	LIMIT_IP_AND_PATH                     // IP + 路由地址
	// LIMIT_USER                            // 仅用户
)

func limitKey(c *gin.Context, lt LimitKey) string {
	switch lt {
	case LIMIT_IP:
		return c.ClientIP()
	case LIMIT_IP_AND_PATH:
		return c.ClientIP() + c.FullPath()
	default:
		return c.ClientIP()
	}
}

/* 限流器 (基于rate类库 + 令牌桶算法)
 * interval Token 桶中放置 Token 的间隔
 * burst    Token 桶的容量大小
 * expire   limiter 过期时间(回收)
 * eg: NewLimiter(rate.Every(100 * time.Millisecond), 1) 表示每 100ms 往桶中放一个 Token，本质上也就是一秒钟产生 10 个。
 */
func ReteLimit(lt LimitKey, interval time.Duration, burst int, expire time.Duration) gin.HandlerFunc {
	return limit.NewRateLimiter(func(c *gin.Context) string {
		return limitKey(c, lt)
	}, func(c *gin.Context) (*rate.Limiter, time.Duration) {
		return rate.NewLimiter(rate.Every(interval), burst), expire
	}, func(c *gin.Context) {
		c.Abort()
		tool.Response(c, erresp.FrequencyExceeds)
	})
}

/* 限流器 (基于redis + lua + 令牌桶算法)
 * interval Token 桶中放置 Token 的间隔 （毫秒）
 * burst    Token 桶的容量大小
 * expire   limiter 过期时间(回收) (毫秒)
 */
func RLTBLimit(lt LimitKey, interval time.Duration, burst int, expire time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		conn := lib.RedisPool().Get()
		lua := redis.NewScript(1, LIMIT_TOKEN_BUCKET)
		arg := []interface{}{
			limitKey(c, lt),             // key
			burst,                       // ARGV[1] bucket_cap 令牌桶容量
			interval.Milliseconds(),     // ARGV[2] interval 放令牌间隔（毫秒）
			time.Now().UnixNano() / 1e6, // ARGV[3] curr_timestamp 获取当前 (毫秒)
			expire.Milliseconds(),       // ARGV[4] expire_time 过期时间 (毫秒)
		}
		args := redis.Args{}.AddFlat(arg)
		in, err := redis.Int(lua.Do(conn, args...))
		if err != nil {
			c.Abort()
			tool.Response(c, erresp.Redis.WithPrompt(err.Error()))
			return
		}
		if in != 1 {
			c.Abort()
			tool.Response(c, erresp.FrequencyExceeds)
			return
		}
		c.Next()
	}
}

// Lua内容
const (
	// 令牌桶算法
	LIMIT_TOKEN_BUCKET = `
	-- 返回码：
	local SUCCESS = 1             -- 操作成功
	local FAILED = 0              -- 操作失败

	local key = KEYS[1]                       -- key
	local bucket_cap = tonumber(ARGV[1])      -- 令牌桶容量
	local interval = tonumber(ARGV[2])        -- 放令牌间隔(毫秒)
	local cur_token_count = bucket_cap      -- 目前令牌桶中的令牌数量（默认桶容量）
	local cur_timestamp = tonumber(ARGV[3])   -- 当前时间戳（毫秒）
	local expire_time = tonumber(ARGV[4])     -- 过期时间（毫秒）
	
	-- （验证请求）桶容量、令牌间隔时间，必须大于 0
    if bucket_cap <= 0 or interval <= 0 then
		return FAILED
    end
	-- 过期时间过小
	if expire_time <= interval then
		return FAILED
    end
	
	-- 桶是否存在
	local exi = redis.call("EXISTS", key)
	if exi == 0 then  -- 不存在
        redis.call("HMSET", key, 
		"last_timestamp", cur_timestamp, 
		"cur_token_count", cur_token_count - 1) -- 首次请求，默认为满桶，消耗一个 token
        -- 设置 redis 的过期时间
		redis.call("EXPIRE", key, expire_time)
		return SUCCESS
	end

	local arr = redis.pcall("HMGET", KEYS[1], "last_timestamp", "cur_token_count")
    if arr == nil then -- 空内容
        return FAILED
    end

	local last_timestamp = tonumber(arr[1])
	cur_token_count =  tonumber(arr[2]) -- 令牌桶的 token
	-- 计算上一次放令牌到现在的时间间隔中，一共应该放入多少令牌
	local reserve_count = math.max(0, math.floor((cur_timestamp - last_timestamp) / interval))
	local new_count = math.min(bucket_cap, cur_token_count + reserve_count)

	-- 无令牌可用
	if new_count <= 0 then
		-- 更新数据
		redis.call("HMSET", key, "last_timestamp", last_timestamp, "cur_token_count", new_count)
		-- 设置 redis 的过期时间
		redis.call("EXPIRE", key, expire_time)

		return FAILED
	end

	-- 更新当前桶中的令牌数量 
	-- 如果这次有放入令牌，则更新时间
	redis.pcall("HSET", key, "last_timestamp", cur_timestamp, "cur_token_count", new_count -1)
	redis.call("EXPIRE", key, expire_time) -- 设置 redis 的过期时间

	return SUCCESS`
)
