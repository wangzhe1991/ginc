package router

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"{{.ProjectModule}}/conf"

	"gitee.com/krio/helper/logger"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

var (
	baseFileName = "/api.swagger.json" // swagerr首页，注意：这里要和gpgc里的设置成同名称
)

func initSwagger(g *gin.Engine) *gin.Engine {
	swaggerConf := conf.C.Swagger
	if swaggerConf.Enable { // 是否开启swagger
		// 加载所有swagger.json文件静态资源
		err := filepath.Walk(swaggerConf.Dir, func(path string, info os.FileInfo, err error) error {
			if strings.HasSuffix(info.Name(), ".json") {
				f := func(v string) string {
					vv := strings.Split(v, ".")
					if len(vv) > 0 {
						return vv[0]
					}
					return v
				}
				fileName := fmt.Sprintf("swagger.%s.json", f(info.Name()))
				g.StaticFile(fileName, swaggerFilePath(swaggerConf.Dir, info.Name()))
			}
			return nil
		})
		if err != nil {
			logger.Error(err)
		}
		g.StaticFile(baseFileName, swaggerFilePath(swaggerConf.Dir, baseFileName))
		g.GET("/api/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler, ginSwagger.URL(baseFileName)))
	}
	return g
}

// 拼接swagger文件名称
func swaggerFilePath(dir, name string) string {
	return fmt.Sprintf("%s/%s", dir, name)
}
