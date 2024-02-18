package lib

import (
	"{{.ProjectModule}}/conf"

	"gitee.com/krio/helper/logger"
)

// 自定义日志
func InitLogger() {
	logConf := conf.C.Logger
	log := logger.NewLogger(
		logger.SetLevel(logConf.Level),
		logger.SetDebug(logConf.Debug),
		logger.SetFilePath(logConf.FilePath),
		logger.SetField(logConf.TraceKey),
	)
	logger.SetDefault(log)
}
