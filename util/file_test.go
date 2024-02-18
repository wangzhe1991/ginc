package util

import (
	"testing"
)

func TestCreate(t *testing.T) {
	_, err := Create("test.go")
	t.Log(err)
}

// func TestHandleTemplateFiles(t *testing.T) {
// 	HandleTemplateFiles()
// }

// func TestGetClientTempFileName(t *testing.T) {
// 	GetClientTempFileName()
// }
