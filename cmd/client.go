/*
Copyright © 2021 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"fmt"

	"github.com/gobuffalo/packr/v2"
	"github.com/gookit/color"
	"github.com/spf13/cobra"

	"gitee.com/krio/gpgc/gen"
	"gitee.com/krio/gpgc/util"
)

// clientCmd represents the client command
var clientCmd = &cobra.Command{
	Use:   "client",
	Short: "创建项目（client端）",
	Long:  `The man was too lazy to write it`,
	Run: func(cmd *cobra.Command, args []string) {
		// 项目已存在
		if util.FileExists("./" + clientName) {
			color.Redp("Project already exists !!! \n")
			return
		}
		if clientModule == "" {
			clientModule = clientName
		}
		pro := gen.Project{
			ProjectName:   clientName,
			ProjectModule: clientModule,
		}
		l := len(fileList)
		for k, v := range fileList {
			file := &gen.FileInfo{
				TemplateURL: v + ".tpl",
				TargetURL:   fmt.Sprintf("./%s/%s", pro.ProjectName, v),
			}
			box := packr.New("gpgc-client", "./template/client")
			content, err := box.FindString(file.TemplateURL)
			if err != nil {
				panic(err)
			}
			file.Content = content
			err = pro.GenerateTemplateFile(file)
			if err != nil {
				panic(err)
			}

			// 进度条打印
			util.PrintC(l, k+1)
		}
		color.Greenp("\n")
		color.Greenp("** 你已经成功创建项目: ", clientName, " \n")
		color.Greenp("** 你要做的事: ( *推荐使用Makefile配置参数 )\n")
		color.Greenp("** 1. go mod tidy \n")
		color.Greenp("** 2. gpgc init \n")
		color.Greenp("** 3. gpgc gen \n")
	},
}

var (
	clientName   string
	clientModule string
)

func init() {
	rootCmd.AddCommand(clientCmd)
	clientCmd.Flags().StringVarP(&clientName, "name", "n", "", "项目名称")
	if err := clientCmd.MarkFlagRequired("name"); err != nil {
		panic(err)
	}
	clientCmd.Flags().StringVarP(&clientModule, "module", "m", "", "项目Module")
}

var (
	fileList = []string{
		".gitignore",
		".golangci.yml",
		"Makefile",
		"README.md",
		"app/model/user.go",
		"cmd/app/app.go",
		"cmd/lib/log.go",
		"cmd/lib/redis.go",
		"conf/config.go",
		"conf/config.yaml",
		"dto/proto/v1/api.proto",
		"dto/proto/v1/example_api.proto",
		"dto/proto/v1/public_api.proto",
		"third_party/google/api/annotations.proto",
		"third_party/google/api/distribution.proto",
		"third_party/google/api/error_reason.proto",
		"third_party/google/api/http.proto",
		"third_party/google/protobuf/any.proto",
		"third_party/google/protobuf/api.proto",
		"third_party/google/protobuf/descriptor.proto",
		"third_party/google/protobuf/empty.proto",
		"third_party/google/protobuf/struct.proto",
		"third_party/protoc-gen-swagger/options/annotations.proto",
		"third_party/protoc-gen-swagger/options/openapiv2.proto",
		"go.mod",
		"main.go",
		"router/middleware/cors.go",
		"router/middleware/jwt.go",
		"router/middleware/limiter.go",
		"router/middleware/metrics.go",
		"router/middleware/nocache.go",
		"router/middleware/recovery.go",
		"router/middleware/tracer.go",
		"router/router.go",
		"router/swagger.go",
		"router/wrapper.go",
		"rpc/rpc.go",
		"tool/response.go",
		"tool/validator.go",
	}
)
