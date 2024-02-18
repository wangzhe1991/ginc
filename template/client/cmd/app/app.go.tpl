package app

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"{{.ProjectModule}}/cmd/lib"
	"{{.ProjectModule}}/conf"
	"{{.ProjectModule}}/router"
	"{{.ProjectModule}}/rpc"

	"gitee.com/krio/helper/logger"
	"github.com/gin-gonic/gin"
	"github.com/gookit/color"
)

func Run() {
	lib.InitLogger() // 日志
	lib.InitRedis()  // redis
	rpc.Init()       // rpc
	cmdPrint()       // cmd print
	startServer()    // 启动
}

// cmd打印参数
func cmdPrint() {
	color.Greenp(fmt.Sprintf("*[ logger: %s ]\n", conf.C.Logger.Level))
	color.Greenp(fmt.Sprintf("*[ redis: %s/%d ]\n", conf.C.Redis.DSN, conf.C.Redis.DB))
	color.Greenp(fmt.Sprintf("*[ swagger: 127.0.0.1:%d/api/swagger/index.html ]\n", conf.C.Gin.Port))
}

// 启动服务
func startServer() {
	ginC := conf.C.Gin
	gin.SetMode(ginC.Mode) // 全局设置环境
	g := gin.Default()     // 获得路由实例
	g = router.InitRouter(g)
	s := &http.Server{
		Addr:           fmt.Sprintf(":%d", ginC.Port),
		Handler:        g,
		ReadTimeout:    10 * time.Second,
		WriteTimeout:   10 * time.Second,
		MaxHeaderBytes: 1 << 20,
	}

	go func() {
		if err := s.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.Fatal("start server failed, err: %v", err)
		}
	}()

	if err := serverClose(s); err != nil {
		logger.Fatal("server shutdown failed, err: ", err)
	}
}

// 优雅关闭
func serverClose(s *http.Server) error {
	// 监听中断信号
	c := make(chan os.Signal, 1)
	signal.Notify(c, syscall.SIGINT, syscall.SIGTERM, syscall.SIGQUIT)
	i := <-c
	logger.Infof("received signal: %v, shutdown server", i)

	// 给程序最多3秒时间处理服务的请求
	timeoutCtx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()

	return s.Shutdown(timeoutCtx)
}
