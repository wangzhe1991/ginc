/*
Copyright © 2021 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	"github.com/gookit/color"
	"github.com/spf13/cobra"
)

const version = "v1.3.0"

// versionCmd represents the version command
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "版本号",
	Long:  `The man was too lazy to write it`,
	Run: func(cmd *cobra.Command, args []string) {
		color.Cyanp("*[ version: ", version, " ] \n")
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
