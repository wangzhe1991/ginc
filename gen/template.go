package gen

import (
	"bytes"
	"text/template"

	"gitee.com/krio/gpgc/util"
)

type Project struct {
	ProjectName   string
	ProjectModule string
}
type FileInfo struct {
	TemplateURL string
	TargetURL   string
	Content     string
}

func (p *Project) GenerateTemplateFile(file *FileInfo) error {
	tmpl, err := template.New("gpgc").Parse(file.Content)
	if err != nil {
		return err
	}
	var buf bytes.Buffer
	if err = tmpl.Execute(&buf, &p); err != nil {
		return err
	}

	f, err := util.Create(file.TargetURL)
	if err != nil {
		return err
	}

	_, err = f.WriteString(buf.String())
	if err != nil {
		return err
	}
	defer f.Close()
	return nil
}
