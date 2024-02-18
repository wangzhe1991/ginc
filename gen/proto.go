package gen

import (
	"os"
	"strings"

	"github.com/emicklei/proto"
)

// Service represents a service definition is a proto file.
type Service struct {
	PackageName  string // 包名
	PackageAlias string // 包名别名
	Name         string // service名称
	File         string // proto文件url
	APIs         []*API // 接口
	NodeName     string // 注释名称
}

// API represents a rpc definition in a proto file, corresponding to a gin controller.
type API struct {
	Name       string
	Desc       string
	Method     string
	URL        string
	TargetFile string
	Request    *Message
	Response   *Message
}

// Message represents a message definition in a proto file.
type Message struct {
	Name string
	// File is the proto file where it's defined.
	File   string
	Fields []*Field
}

// Field represents a field definition in a proto message.
// We only need its inline comment to modify go tags so we don't parse the comment.
type Field struct {
	Name          string
	InlineComment string
}

func parseProtos(protos []string) ([]*Service, error) {
	// msgs := make(map[string]*Message)
	srvs := make([]*Service, 0)
	for _, p := range protos {
		if err := parseProto(p, &srvs); err != nil {
			return nil, err
		}
	}
	// fill Request and Response of APIs
	// for _, srv := range srvs {
	// 	for _, api := range srv.APIs {
	// 		api.Request = msgs[api.Request.Name]
	// 		if api.Request == nil {
	// 			return nil, fmt.Errorf("not found definition `%v` of %v's request", api.Request.Name, api.Name)
	// 		}
	// 		api.Response = msgs[api.Response.Name]
	// 		if api.Response == nil {
	// 			return nil, fmt.Errorf("not found definition `%v` of %v's response", api.Response.Name, api.Name)
	// 		}
	// 	}
	// }

	return srvs, nil
}

// 解析proto文件内容
func parseProto(file string, srvs *[]*Service) error {
	reader, err := os.Open(file)
	if err != nil {
		return err
	}
	defer reader.Close()

	p := proto.NewParser(reader)
	d, err := p.Parse()
	if err != nil {
		return err
	}

	for _, e := range d.Elements {
		switch v := e.(type) {
		case *proto.Service: // 解析service
			*srvs = append(*srvs, parseService(v, file))
			// case *proto.Message: // 解析message
			// msgs[v.Name] = parseMessage(v, file)
		}
	}
	return nil
}

type Target struct {
	PackageName string
	TargetFile  string
	NodeName    string
}

const ControllerStr = "controller"

// 获取要生成的目标 路径+文件名称 和 controller包名
func getTarget(s string) *Target {
	var (
		packageName = ControllerStr
		targetFile  = ControllerStr + ".go"
		nodeName    = "未分组"
	)
	// 清除左右空格
	s = strings.TrimSpace(s)
	slc := strings.Split(s, "|")
	// 提取注释中的go文件路径
	if len(slc) > 0 {
		fileUrl := slc[0]
		i := strings.Index(fileUrl, ".go")
		if i != -1 {
			targetFile = fileUrl[0 : i+3]
			s := strings.Split(targetFile, "/") // 这里获取controller的包名，如：v1/example.go => v1
			l := len(s)
			if l > 1 {
				packageName = s[l-2]
			}
		}
	}
	// 注释名称
	if len(slc) > 1 {
		nodeName = slc[1]
	}
	return &Target{
		PackageName: packageName,
		TargetFile:  targetFile,
		NodeName:    nodeName,
	}
}

// 解析service
func parseService(ps *proto.Service, file string) *Service {
	cPathLine := ControllerStr + ".go"
	if ps.Comment != nil {
		cPathLine = ps.Comment.Lines[0]
	}
	tar := getTarget(cPathLine)
	s := &Service{
		PackageName:  tar.PackageName,
		PackageAlias: ControllerStr + tar.PackageName,
		Name:         ps.Name,
		File:         file,
		NodeName:     tar.NodeName,
	}

	for _, e := range ps.Elements {
		switch v := e.(type) {
		// case *proto.Comment:
		case *proto.RPC:
			s.APIs = append(s.APIs, parseRPC(v, tar.TargetFile))
			// case *proto.Package:
		}
	}
	return s
}

// 解析RPC
func parseRPC(pr *proto.RPC, file string) *API {
	var desc string
	if pr.Comment != nil {
		desc = strings.TrimSpace(pr.Comment.Lines[0])
	}
	a := &API{
		Name:       pr.Name,
		Desc:       desc,
		TargetFile: file,
		Request:    &Message{Name: pr.RequestType},
		Response:   &Message{Name: pr.ReturnsType},
	}
	for _, e := range pr.Elements {
		switch v := e.(type) {
		case *proto.Option:
			for k, vv := range v.Constant.Map {
				if vv.IsString && (k == "get" || k == "post" || k == "put" || k == "patch" || k == "delete") {
					a.Method = k
					a.URL = vv.Source
				}
			}
		}
	}
	return a
}

// func parseMessage(pm *proto.Message, file string) *Message {
// 	m := &Message{
// 		Name: pm.Name,
// 		File: file,
// 	}
// 	for _, e := range pm.Elements {
// 		switch v := e.(type) {
// 		case *proto.NormalField:
// 			field := &Field{Name: v.Name}
// 			if v.InlineComment != nil && len(v.InlineComment.Lines) > 0 {
// 				field.InlineComment = strings.TrimSpace(v.InlineComment.Lines[0])
// 			}
// 			m.Fields = append(m.Fields, field)
// 		}
// 	}
// 	return m
// }
