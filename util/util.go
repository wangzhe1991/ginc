package util

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

func GetModule() string {
	dir, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	f, err := os.Open(dir + "/go.mod")
	if err != nil {
		fmt.Printf("cannot open go.mod: %v\nYou should run `ginc gen` in a go module project\n", err)
		os.Exit(1)
	}
	defer f.Close()

	rd := bufio.NewReader(f)
	line, err := rd.ReadString('\n')
	if err != nil && err != io.EOF {
		fmt.Printf("cannot read go.mod: %v\n", err)
		os.Exit(1)
	}
	if !strings.HasPrefix(line, "module ") {
		fmt.Printf("go.mod invalid format")
	}
	return strings.TrimSpace(line[7:])
}

func GetProtoFiles(protoFile string) []string {
	files, err := filepath.Glob(protoFile + "/*.proto")
	if err != nil {
		panic(err)
	}

	return files
}

func GetPbFiles(pbFile string) []string {
	files, err := filepath.Glob(pbFile + "/*.pb.go")
	if err != nil {
		panic(err)
	}

	return files
}

func GetSwaggerFiles(swaggerFile string) []string {
	files, err := filepath.Glob(swaggerFile + "/*.swagger.json")
	if err != nil {
		panic(err)
	}

	return files
}

// 根据pbPath获取pb别名字段
func GetPbAlias(pbPath string) string {
	var pbAlias = "pb"
	if pbPath == "" {
		return pbAlias
	}
	s := strings.Split(pbPath, "/")
	l := len(s)
	if l > 0 {
		pbAlias = s[l-2]+strings.ToUpper(s[l-1]) // pb/v1 => pbV1
	}
	return pbAlias
}
