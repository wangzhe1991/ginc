package router

import (
	"{{.ProjectModule}}/router/middleware"

	"github.com/gin-gonic/gin"
)

func InitRouter(g *gin.Engine) *gin.Engine {
	// metrics采样（普罗米修斯）
	// gp := middleware.New(g)
	// g.Use(gp.Middleware())
	// g.GET("/metrics", gin.WrapH(promhttp.Handler()))

	// swagger API文档
	g = initSwagger(g)
	// 全局中间件
	g.Use(
		middleware.Recover, // 全局异常处理
		middleware.Cors,    // 跨域
		middleware.Tracer,  // 链路追踪
	)
	return g
}
