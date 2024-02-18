package cmd

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"regexp"
	"strings"

	"github.com/gookit/color"
	"github.com/spf13/cobra"

	"gitee.com/krio/gpgc/gen"
	"gitee.com/krio/gpgc/util"
)

// genCmd represents the gen command
var genCmd = &cobra.Command{
	Use:   "gen",
	Short: "根据proto创建api相关：pb、swagger、router、controller等",
	Long:  `The man was too lazy to write it`,
	Run: func(cmd *cobra.Command, args []string) {
		gen.Gener.ProtoFiles = util.GetProtoFiles(gen.Gener.ProtoPath)
		if len(gen.Gener.ProtoFiles) <= 0 {
			panic("there was no one proto file there")
		}
		gen.Gener.GoModule = util.GetModule()
		// cmd printC
		color.Bluep("[ 配置列表 ]", "\n")
		color.Cyanp(fmt.Sprintf("* proto:       %s \n", gen.Gener.ProtoPath))
		color.Cyanp(fmt.Sprintf("* pb:          %s \n", gen.Gener.PbPath))
		color.Cyanp(fmt.Sprintf("* swagger:     %s \n", gen.Gener.SwaggerPath))
		color.Cyanp(fmt.Sprintf("* third_party: %s \n", gen.Gener.ThirdPartyPath))
		color.Cyanp(fmt.Sprintf("* sdk:         %s \n", gen.Gener.SdkPath))
		color.Cyanp(fmt.Sprintf("* controller:  %s \n", gen.Gener.ControllerPath))
		color.Cyanp(fmt.Sprintf("* router:      %s \n", gen.Gener.RouterFile))

		// 生成pb、swagger等文件
		if err := handlePortoGen(); err != nil {
			panic(err)
		}
		// 处理tag
		if err := handleTagGen(); err != nil {
			panic(err)
		}
		// 生成controller模板文件
		err := gen.Gener.Gen()
		if err != nil {
			panic(err)
		}
		// 处理swagger
		if err := formatSwaggerFile(); err != nil {
			panic(err)
		}
	},
}

func init() {
	rootCmd.AddCommand(genCmd)
	// 参数
	gen.Gener = &gen.Generator{}
	genCmd.Flags().StringVarP(&gen.Gener.ProtoPath, "proto", "p", "dto/proto/v1", "设置proto文件目标路径，默认: dto/proto/v1")
	genCmd.Flags().StringVarP(&gen.Gener.PbPath, "pb", "b", "dto/pb/v1", "设置生成pb文件路径，默认: dto/pb/v1")
	genCmd.Flags().StringVarP(&gen.Gener.SwaggerPath, "swagger", "w", "dto/swagger/v1", "设置生成swagger文件路径，默认: dto/swagger/v1")
	genCmd.Flags().StringVarP(&gen.Gener.ThirdPartyPath, "third_party", "t", "third_party", "设置third party引用路径，默认: third_party")
	genCmd.Flags().StringVarP(&gen.Gener.SdkPath, "sdk", "s", "sdk", "设置sdk引用路径，默认: sdk")
	genCmd.Flags().StringVarP(&gen.Gener.ControllerPath, "controller", "c", "app/controller", "设置生成controller文件路径，默认: app/controller/v1")
	genCmd.Flags().StringVarP(&gen.Gener.RouterFile, "router", "r", "router/router.go", "设置路由文件，默认: router/router.go")
}

// 执行cmd命令：生成pb、swagger等
func handlePortoGen() error {
	if err := util.FileExistsOrCreate(gen.Gener.PbPath); err != nil {
		return err
	}
	if err := util.FileExistsOrCreate(gen.Gener.SwaggerPath); err != nil {
		return err
	}
	color.Bluep("[ 开始处理：pb、swagger、controller、router ]", "\n")
	args := []string{
		fmt.Sprintf("--proto_path=%s", gen.Gener.ProtoPath),      // proto
		fmt.Sprintf("--proto_path=%s", gen.Gener.ThirdPartyPath), // third_party
		fmt.Sprintf("--proto_path=%s", gen.Gener.SdkPath),        // sdk proto
		"--go_out=.", // pb 注意：新的protoc-gen-go插件已经不支持plugins选项，pb文件生成路径靠go_package参数
		fmt.Sprintf("--openapiv2_out=allow_merge=true,json_names_for_fields=false,enums_as_ints=true,omit_enum_default_value=true:%s", gen.Gener.SwaggerPath), // swagger
		// fmt.Sprintf("--swagger_out=logtostderr=true:%s", Gener.SwaggerPath), // swagger
		// "--go-grpc_out=.", // 仅作为api没必要加
	}
	// 获取所有proto文件名称
	args = append(args, gen.Gener.ProtoFiles...)
	cmd := exec.Command("protoc", args...)
	cmd.Stderr = os.Stderr
	_, err := cmd.Output()
	if err != nil {
		return err
	}
	for _, v := range cmd.Args {
		color.Cyanp("|* ", v, "\n")
	}
	return nil
}

// 使用inject_tag处理pb的tag : github.com/favadi/protoc-go-inject-tag
func handleTagGen() error {
	// 获取所有pb文件名称
	pbs := util.GetPbFiles(gen.Gener.PbPath)
	if len(pbs) <= 0 {
		return nil
	}
	color.Bluep("[ 处理： tag标签 ]", "\n")
	for _, v := range pbs {
		cmd := exec.Command("protoc-go-inject-tag", fmt.Sprintf("-input=%s", v))
		cmd.Stderr = os.Stderr
		_, err := cmd.Output()
		if err != nil {
			return err
		}
		color.Cyanp("|* ", v, "\n")
		// 去除忽略 omitempt
		err = modifyTag(v)
		if err != nil {
			panic(err)
		}
	}
	return nil
}

// 编辑 api/swagger.json的info.description
func formatSwaggerFile() error {
	// TODO 这里需要根据swagger情况调整
	apiSwagger := gen.Gener.SwaggerPath + "/apidocs.swagger.json"
	if !util.FileExists(apiSwagger) {
		return nil
	}
	b, err := ioutil.ReadFile(apiSwagger)
	if err != nil {
		return err
	}
	body := string(b)
	color.Bluep("[ 文档分组 ]", "\n")
	var maxNameLen int
	for svcName := range gen.Gener.ServiceNodeMap {
		length := len(svcName)
		if length > maxNameLen {
			maxNameLen = length
		}
	}
	for svcName, nodeName := range gen.Gener.ServiceNodeMap {
		complexStr := fmt.Sprintf(`"%s"`, svcName)
		if strings.Contains(body, complexStr) {
			reg := regexp.MustCompile(complexStr)
			fs := reg.FindString(body)
			body = strings.ReplaceAll(body, fs, "\""+nodeName+"\"")
		}
		colorCyanp(svcName, nodeName, maxNameLen)
	}
	if err = ioutil.WriteFile(apiSwagger, []byte(body), 0644); err != nil {
		return err
	}
	return nil
}

// 调整pb的tag（主要批量清除json标签里的omitempty）
func modifyTag(fileName string) error {
	b, err := ioutil.ReadFile(fileName)
	if err != nil {
		return nil
	}
	pb := string(b)
	pb = strings.ReplaceAll(pb, ",omitempty", "")
	return ioutil.WriteFile(fileName, []byte(pb), 0644)
}

func colorCyanp(str1 string, str2 string, maxLen int) {
	num := maxLen - len(str1)
	var spaceStr string
	for i := 0; i < num; i++ {
		spaceStr = spaceStr + " "
	}
	color.Cyanp("|* ", str1, spaceStr, " => ", str2, "\n")
}
