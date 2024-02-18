package rpc

import (
	"context"
	"{{.ProjectModule}}/conf"
	"time"

	"gitee.com/krio/helper/logger"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"
	"google.golang.org/grpc/backoff"
	"google.golang.org/grpc/metadata"
)

var (
// UserClient    pb.UserClient
)

func Init() {
	// UserClient = pb.NewUserClient(pbConn)
}

// 创建存根
func mustDial(addr string) *grpc.ClientConn {
	// 单位是字节, 参数类型是int, 也就是最大支持发送接收为2G-1个字节
	// 既可以接收大小 grpc.MaxCallRecvMsgSize(1024 * 1024 * 20)
	// 可扩展发送大小 grpc.MaxCallSendMsgSize(1024*1024*20)
	c, err := grpc.Dial(addr, grpc.WithInsecure(), grpc.WithDefaultCallOptions(grpc.MaxCallRecvMsgSize(1024*1024*200)), grpc.WithConnectParams(grpc.ConnectParams{
		MinConnectTimeout: time.Second * 3, // 最小连接超时
		Backoff:           backoff.DefaultConfig,
	}))
	// 你可以使用 DialOptions 在 grpc.Dial 中设置授权认证（如， TLS，GCE认证，JWT认证），
	// 如果服务有这样的要求的话 —— 但是对于 RouteGuide 服务，我们不用这么做。
	if err != nil {
		logger.Fatalf("dial grpc %v failed, err: %v", addr, err)
	}

	return c
}

// 处理grpc的meta-Data
func FormatCtx(c *gin.Context) context.Context {
	kvSli := make([]string, 0)
	// 链路追踪
	keys := conf.C.Logger.TraceKey
	for _, key := range keys {
		if t, exist := c.Get(key); exist {
			kvSli = append(kvSli, key, t.(string))
		}
	}

	return metadata.AppendToOutgoingContext(context.Background(), kvSli...)
}