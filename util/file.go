package util

import (
	"go/format"
	"io/ioutil"
	"os"
	"strings"

	"golang.org/x/tools/imports"
)

// OpenOrCreate opens a file if it exists, otherwise creates it.
// If the file path contains directories, it will make them first.
func OpenOrCreate(file string) (*os.File, error) {
	if FileExists(file) {
		return os.OpenFile(file, os.O_RDWR|os.O_APPEND, 0644)
	}
	if i := strings.LastIndex(file, "/"); i != -1 {
		if err := os.MkdirAll(file[:i], 0755); err != nil {
			return nil, err
		}
	}
	return os.Create(file)
}

// Creates or truncates the named file,if the file path contains directories, it will make them first.
func Create(file string) (*os.File, error) {
	if !FileExists(file) {
		if i := strings.LastIndex(file, "/"); i != -1 {
			if err := os.MkdirAll(file[:i], 0755); err != nil {
				return nil, err
			}
		}
	}
	return os.Create(file)
}

// FileExists checks whether a file exists.
func FileExists(file string) bool {
	if _, err := os.Stat(file); os.IsNotExist(err) {
		return false
	}
	return true
}

// GoFormat formats go file in canonical gofmt style and fix import statements.
func GoFormat(file string) error {
	c, err := ioutil.ReadFile(file)
	if err != nil {
		return err
	}
	c, err = format.Source(c)
	if err != nil {
		return err
	}
	c, err = imports.Process(file, c, nil)
	if err != nil {
		return err
	}
	return ioutil.WriteFile(file, c, 0666)
}

// 文件是否存在，不存递归创建文件夹
func FileExistsOrCreate(dir string) error {
	exi := FileExists(dir)
	if !exi {
		// 创建文件夹
		return os.MkdirAll(dir, os.ModePerm)
	}

	return nil
}

// func GetClientTempFileName() {
// 	files, err := utils.GetAllFileName("../template/client")
// 	if err != nil {
// 		panic(err)
// 	}
// 	for _, v := range files {
// 		fmt.Println("\"" + v + "\"")
// 	}
// }

// // 处理模板文件
// func HandleTemplateFiles() {
// 	files, err := utils.GetAllFileName("/Users/lucusjia/go/src/gitee.com/krio/example")
// 	if err != nil {
// 		panic(err)
// 	}
// 	for _, v := range files {
// 		fmt.Println(v)
// 		// err := os.Rename(v, v+".tpl")
// 		// if err != nil {
// 		// 	panic(err)
// 		// }
// 	}
// }
