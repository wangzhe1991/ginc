/*
Copyright © 2021 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"github.com/spf13/cobra"
	"gitee.com/krio/gpgc/util"
)

// initCmd represents the init command
var initCmd = &cobra.Command{
	Use:   "init",
	Short: "初始安装必要类库",
	Long:  `The man was too lazy to write it`,
	Run: func(cmd *cobra.Command, args []string) {
		// golang 1.17+
		_, err := util.GoInstallCmd("google.golang.org/protobuf/cmd/protoc-gen-go@latest")
		if err != nil {
			panic(err)
		}
		_, err = util.GoInstallCmd("google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest")
		if err != nil {
			panic(err)
		}
		// _, err = util.GoInstallCmd("github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@latest")
		// if err != nil {
		// 	panic(err)
		// }
		_, err = util.GoInstallCmd("github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest")
		if err != nil {
			panic(err)
		}
		_, err = util.GoInstallCmd("github.com/wangzhe1991/protoc-gen-go-errorx@latest")
		if err != nil {
			panic(err)
		}
		_, err = util.GoInstallCmd("github.com/favadi/protoc-go-inject-tag@latest")
		if err != nil {
			panic(err)
		}
	},
}

func init() {
	rootCmd.AddCommand(initCmd)
}
