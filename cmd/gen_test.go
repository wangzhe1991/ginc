/*
Copyright © 2021 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"testing"

	"gitee.com/krio/gpgc/util"
)

func Test_cmdGen(t *testing.T) {
	protos := util.GetProtoFiles("../example/proto/v1")
	if err := handlePortoGen("../example/proto/v1", "../example/pb/v1", "../example/swagger/v1", "../example/third_party", protos); err != nil {
		t.Log(err)
	}
	t.Log("ok!")
}

func Test_injectTagGen(t *testing.T) {
	if err := handleTagGen("../example/pb/v1"); err != nil {
		t.Log(err)
	}
	t.Log("ok!")
}
