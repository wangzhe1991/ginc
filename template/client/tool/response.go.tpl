package tool

import (
	"gitee.com/krio/erresp"
	"github.com/gin-gonic/gin"
)

func Response(c *gin.Context, resp erresp.Erresp) {
	c.JSON(resp.GetHTTPStatus(), resp)
}
