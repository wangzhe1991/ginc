package conf

import (
	"flag"

	"gitee.com/krio/helper/logger"
	"github.com/spf13/viper"
)

var (
	C    *Config
	file string
)

func init() {
	// flag自定义配置地址
	flag.StringVar(&file, "f", "./conf/config.yaml", "config file path")
	flag.Parse()

	viper.SetConfigFile(file)
	if err := viper.ReadInConfig(); err != nil {
		logger.Panicf("read config failed, err: %v", err)
	}
	if err := viper.Unmarshal(&C); err != nil {
		logger.Panicf("config viper unmarshal failed, err: %v", err)
	}
}

type Config struct {
	Gin             *Gin
	Logger          *Logger
	Swagger         *Swagger
	RequestValidate *RequestValidate
	Redis           *Redis
	JWT             *JWT
	GRPC            *GRPC
}

// gin框架配置
type Gin struct {
	Mode string // 模式：debug|release|test
	Port int32  // 端口
}

// 日志配置
type Logger struct {
	Level    string // 错误等级： debug|info|warn|error|fatal
	Debug    bool
	FilePath string
	TraceKey []string
}

// swagger文档
type Swagger struct {
	Dir    string // 地址
	Enable bool   // 是否开启
}

// gRPC地址
type GRPC struct {
	PbAddr string
}

// jwt配置
type JWT struct {
	SignKey     string
	ExpiresTime int
	Issuer      string
}

// 请求参数验证配置
type RequestValidate struct {
	Language string
}

// redis配置
type Redis struct {
	DSN      string // URL
	Password string // 密码
	MaxIdle  int    // 最大空闲数
	DB       int    // DB
}

