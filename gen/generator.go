package gen

import (
	"gitee.com/krio/gpgc/util"
)

// Generator is responsible to init project and generates codes from proto.
type Generator struct {
	GoModule       string
	ProtoPath      string
	ProtoFiles     []string
	PbPath         string
	PbAlias        string
	PbFiles        []string
	ControllerPath string
	RouterFile     string
	ThirdPartyPath string
	SdkPath        string
	SwaggerPath    string
	ServiceNodeMap map[string]string
}

// New returns a new instance of Generator.
func NewGenerator(gener *Generator) *Generator {
	return &Generator{
		GoModule:       gener.GoModule,
		ProtoPath:      gener.ProtoPath,
		ProtoFiles:     gener.ProtoFiles,
		PbPath:         gener.PbPath,
		PbAlias:        util.GetPbAlias(gener.PbPath),
		PbFiles:        gener.PbFiles,
		ControllerPath: gener.ControllerPath,
		RouterFile:     gener.RouterFile,
		ThirdPartyPath: gener.ThirdPartyPath,
		SdkPath:        gener.SdkPath,
		ServiceNodeMap: gener.ServiceNodeMap,
	}
}
func (gener *Generator) WithServiceNodeMap(m map[string]string) *Generator {
	gener.ServiceNodeMap = m
	return gener
}

// // 根据pbPath获取pb别名字段
// func getPbAlias(pbPath string) string {
// 	var pbAlias = "pb"
// 	if pbPath == "" {
// 		return pbAlias
// 	}
// 	s := strings.Split(pbPath, "/")
// 	l := len(s)
// 	if l > 0 {
// 		pbAlias = s[l-2]+strings.ToUpper(s[l-1]) // pb/v1 => pbV1
// 	}
// 	return pbAlias
// }
