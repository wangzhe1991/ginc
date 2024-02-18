package middleware

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Options is a middleware function that appends headers
// for options requests and aborts then exits the middleware
// chain and ends the request.
func Cors(c *gin.Context) {
	defer func() {
		// 请求头部
		origin := c.Request.Header.Get("Origin")
		// 接收客户端发送的origin （重要！）
		c.Header("Access-Control-Allow-Origin", origin)
		c.Header("Access-Control-Max-Age", "86400")
		c.Header("Access-Control-Allow-Methods", "GET,POST,PUT,PATCH,DELETE,OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Length,Access-Control-Allow-Origin,Access-Control-Allow-Headers,Content-Type,Authorization")
		c.Header("Access-Control-Allow-Credentials", "true")

		// Option Pass~
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
		}
	}()
	// 处理请求
	c.Next()
}
