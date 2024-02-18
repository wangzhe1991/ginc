package gen

import (
	"fmt"
	"io/ioutil"
	"regexp"
	"strings"

	"gitee.com/krio/gpgc/util"
)

func (g *Generator) genRouter(srv *Service, api *API) error {
	// 读取文件
	fileBytes, err := ioutil.ReadFile(g.RouterFile)
	if err != nil {
		return nil
	}
	// 生产api路由常量表
	router := string(fileBytes)
	// TODO 这里针对gin和自定义，根据实际情况自行修改
	initFuncReg := regexp.MustCompile(`func InitRouter\(g \*gin\.Engine\) \*gin\.Engine {([\s\S]+?)\n}`)
	importReg := regexp.MustCompile(`import \(([\s\S]+?)\)`)
	init := initFuncReg.FindString(router)
	if !strings.Contains(init, api.URL) {
		r := api.formatGinRoute(srv.PackageAlias)
		newInit := init[:len(init)-12] + r + init[len(init)-11:] // 注意： 这里根据的是 return g
		router = strings.Replace(router, init, newInit, 1)
	}

	controllerImport := fmt.Sprintf(`"%s/%s/%s"`, g.GoModule, g.ControllerPath, srv.PackageName)
	if !strings.Contains(router, controllerImport) {
		controllerImport = fmt.Sprintf("%s %s", srv.PackageAlias, controllerImport)
		imports := importReg.FindString(router)
		newImports := imports[:len(imports)-2] + "\n" + controllerImport + "\n" + imports[len(imports)-1:]
		router = strings.Replace(router, imports, newImports, 1)
	}

	if err = ioutil.WriteFile(g.RouterFile, []byte(router), 0644); err != nil {
		panic(err)
	}
	if err = util.GoFormat(g.RouterFile); err != nil {
		fmt.Printf("Failed to gofmt code %v, err=%v\n", g.RouterFile, err)
	}
	return nil
}

// 格式化gin框架路由
func (api *API) formatGinRoute(packageAs string) string {
	return fmt.Sprintf(`\n g.%s("%s", wrapper(%s.%s)) \n`, strings.ToUpper(api.Method), api.URL, packageAs, api.Name)
}

// 格式化路由常量
func (api *API) formatRouteConst(packageAs string) string {
	return fmt.Sprintf(`\n g.%s("%s", wrapper(%s.%s)) \n`, strings.ToUpper(api.Method), api.URL, packageAs, api.Name)
}
