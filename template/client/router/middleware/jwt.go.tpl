package middleware

import (
	"{{.ProjectModule}}/conf"
	"{{.ProjectModule}}/tool"

	"gitee.com/krio/erresp"
	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
)

// 参数名称
var (
	tokenParam  = "token"  // header字段名称
	claimsParam = "claims" // 荷载参数字段名称
	signKey     string
)

// JWTAuth 中间件，检查token
func JWTAuth(c *gin.Context) {
	defer func() {
		token := c.Request.Header.Get(tokenParam)
		// 初始化一个JWT对象实例
		jwt := NewJWT()
		// 解析token中包含的相关信息(有效载荷)
		claims, err := jwt.ParseToken(token)
		if err != nil {
			tool.Response(c, erresp.Parse(err))
			c.Abort()
			return
		}
		// 继续交由下一个路由处理,并将解析出的信息传递下去
		c.Set(claimsParam, claims)
	}()
	c.Next()
}

// JWT 签名结构
type JWT struct {
	SigningKey []byte
}

// 新建一个jwt实例
func NewJWT() *JWT {
	return &JWT{
		[]byte(GetSignKey()),
	}
}

// 载荷，可以加一些自己需要的信息
type CustomClaims struct {
	jwt.StandardClaims
}

// 获取signKey
func GetSignKey() string {
	return conf.C.JWT.SignKey
}

// 这是SignKey
func SetSignKey(key string) string {
	signKey = key
	return signKey
}

// CreateToken 生成一个token
func (j *JWT) CreateToken(claims CustomClaims) (string, error) {
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(j.SigningKey)
}

// 解析Tokne
func (j *JWT) ParseToken(tokenString string) (*CustomClaims, error) {
	if tokenString == "" {
		return nil, erresp.TokenEmpty
	}
	token, err := jwt.ParseWithClaims(tokenString, &CustomClaims{}, func(token *jwt.Token) (interface{}, error) {
		return j.SigningKey, nil
	})
	if err != nil {
		if ve, ok := err.(*jwt.ValidationError); ok {
			switch ve.Errors {
			// 无效
			case jwt.ValidationErrorMalformed:
				return nil, erresp.TokenInvalid
			// 过期
			case jwt.ValidationErrorExpired:
				return nil, erresp.TokenExpired
			// 尚未生效
			case jwt.ValidationErrorNotValidYet:
				return nil, erresp.TokenNotValidYet
			// 其他
			default:
				return nil, erresp.TokenInvalid
			}
		}
	}
	// 将token中的claims信息解析出来并断言成用户自定义的有效载荷结构
	if claims, ok := token.Claims.(*CustomClaims); ok && token.Valid {
		return claims, nil
	}
	return nil, erresp.TokenInvalid
}

func GetClaims(ctx *gin.Context) *CustomClaims {
	// 获取Payload信息
	return ctx.MustGet(tokenParam).(*CustomClaims)
}

// 更新token
// func (j *JWT) RefreshToken(tokenString string) (string, error) {
// 	jwt.TimeFunc = func() time.Time {
// 		return time.Unix(0, 0)
// 	}
// 	token, err := jwt.ParseWithClaims(tokenString, &CustomClaims{}, func(token *jwt.Token) (interface{}, error) {
// 		return j.SigningKey, nil
// 	})
// 	if err != nil {
// 		return "", err
// 	}
// 	if claims, ok := token.Claims.(*CustomClaims); ok && token.Valid {
// 		jwt.TimeFunc = time.Now
// 		claims.StandardClaims.ExpiresAt = time.Now().Add(1 * time.Hour).Unix()
// 		return j.CreateToken(*claims)
// 	}
// 	return "", erresp.TokenInvalid
// }
