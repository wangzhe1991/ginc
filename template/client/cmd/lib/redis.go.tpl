package lib

import (
	"time"

	"{{.ProjectModule}}/conf"

	"gitee.com/krio/helper/logger"
	"github.com/garyburd/redigo/redis"
)

var redisPool *redis.Pool

func InitRedis() *redis.Pool {
	cRedis := conf.C.Redis
	return InitRedisPool(cRedis.DSN, cRedis.Password, cRedis.MaxIdle, cRedis.DB)
}

// InitRedisPool redis连接池
func InitRedisPool(dsn string, password string, maxIdle, db int) *redis.Pool {
	redisPool = &redis.Pool{
		MaxIdle: maxIdle, // 空闲数
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", dsn, redis.DialPassword(password))
			if err != nil {
				return nil, err
			}
			if _, err = c.Do("SELECT", db); err != nil {
				return nil, err
			}
			return c, err
		},
		TestOnBorrow: func(c redis.Conn, t time.Time) error {
			if time.Since(t) > time.Minute {
				_, err := c.Do("PING")
				return err
			}
			return nil
		},
	}
	conn := redisPool.Get()
	defer conn.Close()

	if conn.Err() != nil {
		logger.Panicf("redis pool failed, err: %v", conn.Err())
	}

	if _, err := conn.Do("PING"); err != nil {
		logger.Panicf("redis ping failed, err: %v", err)
	}

	return redisPool
}

func RedisPool() *redis.Pool {
	return redisPool
}
