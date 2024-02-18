package gen

import (
	"github.com/gobuffalo/packr/v2"
)

func init() {
	// 打包模板文件
	_ = packr.New("gpgc-client", "../template/client")
	// s, err := box.FindString("../template/client/*")
	// if err != nil {
	// 	panic(err)
	// }
	// fmt.Println(s)
}
