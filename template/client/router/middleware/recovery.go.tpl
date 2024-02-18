package middleware

import (
	"net/http"
	"runtime/debug"

	"gitee.com/krio/erresp"
	"gitee.com/krio/helper/logger"
	"github.com/gin-gonic/gin"
)

/* 全局统一异常处理
注意 Recover 要尽量放在第一个被加载
如不是的话，在recover前的中间件或路由，将不能被拦截到
程序的原理是：
	1.请求进来，执行recover
	2.程序异常，抛出panic
	3.panic被 recover捕获，返回异常信息，并Abort,终止这次请求
*/
func Recover(c *gin.Context) {
	defer func() {
		if err := recover(); err != nil {
			//打印错误堆栈信息
			logger.Errorf("panic: %v\n", err)
			debug.PrintStack()
			//封装通用json返回
			c.JSON(http.StatusOK, erresp.Parse(err))
			//终止后续接口调用，不加的话recover到异常后，还会继续执行接口里后续代码
			c.Abort()
		}
	}()
	//加载完 defer recover，继续后续接口调用
	c.Next()
}
