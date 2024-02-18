package util

import (
	"errors"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/gookit/color"
)

// GoInstallCmd 初始化必需类库
func GoInstallCmd(arg string) ([]byte, error) {
	if arg == "" {
		return nil, errors.New("无参数")
	}
	cmd := exec.Command("go", "install", arg)
	cmd.Stderr = os.Stderr
	// 终端输出执行内容
	color.Cyanp("|* ", cmd.Args, "\n")

	return cmd.Output()
}

// PrintC 打印进度
func PrintC(l, i int) {
	time.Sleep(100 * time.Millisecond)
	h := strings.Repeat("=", i) + strings.Repeat(" ", l-i)
	color.Yellowp(fmt.Sprintf("\r%.0f%% [%s]", float64(i)/float64(l)*100, h))
}
