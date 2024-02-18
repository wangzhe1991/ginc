package gen

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
	"text/template"

	"gitee.com/krio/gpgc/util"
)

var (
	Gener     *Generator
	headerStr = `package {{.PackageName}}

import (
	{{.PbAlias}} "{{.Module}}/{{.PbPath}}"

	"github.com/gin-gonic/gin"
)

`
	// 基于ginc的func模板string
	funcStr = `// {{.Func.Name}} {{.Func.Desc}}
func {{.Func.Name}}(ctx *gin.Context, req *{{.PbAlias}}.{{.Func.Request}}) (*{{.PbAlias}}.{{.Func.Response}}, error) {
	return &{{.PbAlias}}.{{.Func.Response}}{}, nil // TODO
} `
)

func (g *Generator) Gen() error {
	defer func() {
		if err := recover(); err != nil {
			panic(err)
		}
	}()
	var (
		err error
		m   = make(map[string]string) // proto内容
	)
	g.PbAlias = util.GetPbAlias(g.PbPath)
	srvs, err := parseProtos(g.ProtoFiles)
	if err != nil {
		return err
	}
	serviceNodeMap := make(map[string]string, len(srvs))
	for _, srv := range srvs {
		for _, api := range srv.APIs {
			var (
				exi            bool
				controllerStr  string
				controllerFile = fmt.Sprintf("%s/%s", g.ControllerPath, api.TargetFile)
			)
			// 获取controller内容
			if controllerStr, exi = m[controllerFile]; !exi {
				if controllerStr, err = g.getController(controllerFile); err != nil {
					return err
				}
			}
			cs, err := g.handleController(srv, api, controllerStr)
			if err != nil {
				return err
			}
			if g.RouterFile != "" {
				if err = g.genRouter(srv, api); err != nil {
					return err
				}
			}

			m[controllerFile] = cs
		}
		serviceNodeMap[srv.Name] = srv.NodeName
	}
	Gener = Gener.WithServiceNodeMap(serviceNodeMap)
	if err = g.writeController(m); err != nil {
		return err
	}

	return nil
}

// 获取controller内容
func (g *Generator) getController(file string) (string, error) {
	if util.FileExists(file) {
		b, err := ioutil.ReadFile((file))
		if err != nil {
			os.Exit(1)
			return "", err
		}
		return string(b), nil
	}
	return "", nil
}

// 处理template模板内容
func (g *Generator) handleTemplate(comment, tStr string, c *Controller) (string, error) {
	tmpl, err := template.New("controller").Parse(tStr)
	if err != nil {
		return "", err
	}
	var buf bytes.Buffer
	if err = tmpl.Execute(&buf, c); err != nil {
		return "", err
	}

	return comment + "\n" + buf.String(), nil
}

func (g *Generator) handleController(srv *Service, api *API, comment string) (string, error) {
	if comment == "" {
		var err error
		comment, err = g.handleTemplate(comment, headerStr, &Controller{
			Module:      g.GoModule,
			PackageName: srv.PackageName,
			PbPath:      g.PbPath,
			PbAlias:     g.PbAlias,
		})
		if err != nil {
			return "", err
		}
	} else {
		// 这里处理的是gin框架，其他另行修改
		if strings.Contains(comment, fmt.Sprintf("func %s(ctx *gin.Context", api.Name)) {
			return comment, nil
		}
	}

	return g.handleTemplate(comment, funcStr, &Controller{
		PbAlias: g.PbAlias,
		Func: ControllerFunc{
			Name:     api.Name,
			Desc:     api.Desc,
			Request:  api.Request.Name,
			Response: api.Response.Name,
		},
	})
}

func (g *Generator) writeController(contents map[string]string) error {
	for file, content := range contents {
		f, err := util.Create(file)
		if err != nil {
			return err
		}
		_, err = f.WriteString(content)
		if err != nil {
			return err
		}
		err = f.Close()
		if err != nil {
			return err
		}
		if err = util.GoFormat(file); err != nil {
			fmt.Printf("failed to gofmt code %v, err=%v\n", file, err)
		}
	}
	return nil
}

type ControllerFunc struct {
	Name     string // 函数名称
	Desc     string // 函数描述
	Request  string // 函数请求
	Response string // 函数返回
}

type Controller struct {
	Module      string
	PackageName string // 包名
	PbPath      string // pb文件路径
	PbAlias     string // pb别名
	Func        ControllerFunc
}
