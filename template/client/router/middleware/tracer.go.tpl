package middleware

import (
	"gitee.com/krio/helper/logger"
	"github.com/gin-gonic/gin"
	"github.com/gofrs/uuid"
)

var tracerKey = "X-Trace-Id"

// 全链路跟踪Tracer
func Tracer(c *gin.Context) {
	traceID := getTraceID(c)
	defer func() {
		// Set X-Trace-Id response header
		c.Writer.Header().Add(tracerKey, traceID)
	}()
	// Expose it for use in the application
	c.Set(tracerKey, traceID)
	c.Next()
}

// Create trace id with UUID4
func getTraceID(c *gin.Context) string {
	// Check for incoming header, use it if exists
	traceID := c.Request.Header.Get(tracerKey)
	if traceID == "" {
		u4, err := uuid.NewV4()
		if err != nil {
			logger.Error(err)
			return traceID
		}
		traceID = u4.String()
	}

	return traceID
}
