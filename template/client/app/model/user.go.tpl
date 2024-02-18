package model

import (
	"time"

	"{{.ProjectModule}}/conf"
	"{{.ProjectModule}}/router/middleware"

	"github.com/dgrijalva/jwt-go"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

type User struct {
	SFID        string
	FirstName   string
	LastName    string
	PhoneNumber string
	Password    string
}

// LoginCheck 登录验证
func LoginCheck(req *User) (*User, bool, error) {
	// TODO
	return &User{}, true, nil
}

// GenerateToken 生成令牌
func GenerateToken(ctx *gin.Context, user *User) (*middleware.CustomClaims, string, error) {
	j := middleware.NewJWT()
	// 构造用户claims信息(负荷)
	expiresAt := time.Now().Add(time.Duration(conf.C.JWT.ExpiresTime) * time.Minute).Unix()
	claims := middleware.CustomClaims{
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expiresAt,         // 签名过期时间
			Issuer:    conf.C.JWT.Issuer, // 签名颁发者
			Id:        user.SFID,         // 用户ID
		},
	}
	token, err := j.CreateToken(claims)
	if err != nil {
		return nil, "", err
	}

	return &claims, token, nil
}

// EncryptPWD 密码加密
func EncryptPWD(pwd string) ([]byte, error) {
	return bcrypt.GenerateFromPassword([]byte(pwd), bcrypt.DefaultCost)
}

// CheckPWD 验证密码
func CheckPWD(hashedPwd string, pwd string) error {
	return bcrypt.CompareHashAndPassword([]byte(hashedPwd), []byte(pwd))
}
