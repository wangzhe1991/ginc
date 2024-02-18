package gen

import (
	"fmt"
	"testing"

	"github.com/gobuffalo/packr/v2"
)

func TestProject_CreateMain(t *testing.T) {
	pro := Project{
		ProjectName:   "demo",
		ProjectModule: "demo",
	}
	file := &FileInfo{
		TemplateURL: "go.mod.tpl",
		TargetURL:   fmt.Sprintf("./%s/%s", pro.ProjectName, "go.mod"),
	}
	box := packr.New("gpgc-client", "./template/client")
	content, err := box.FindString(file.TemplateURL)
	if err != nil {
		t.Log(err)
	}
	file.Content = content
	err = pro.GenerateTemplateFile(file)
	if err != nil {
		t.Log(err)
	}
	t.Log("success")

}
