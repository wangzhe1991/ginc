package util

import "testing"

func TestGetModule(t *testing.T) {
	got := GetModule()
	t.Log(got)
}
