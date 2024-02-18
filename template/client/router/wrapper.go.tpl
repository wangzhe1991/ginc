package router

import (
	"reflect"

	"{{.ProjectModule}}/tool"

	"gitee.com/krio/erresp"
	"gitee.com/krio/helper/logger"
	"github.com/gin-gonic/gin"
)

/*
 * 利用反射处理 controller 函数 （装饰器）
 * 1. 请求参数的绑定、验证（详见：github.com/go-playground/validator/v10）
 * 2. 返回封装
 */
// 利用反射处理：请求参数验证、绑定、自定义返回值等
func wrapper(f interface{}) func(*gin.Context) {
	v := reflect.ValueOf(f)
	t := v.Type()
	// 验证是否是func
	if t.Kind() != reflect.Func {
		logger.Panicf("not function")
	}
	// 返回函数的参数数量，不是func会panic
	if t.NumIn() != 2 {
		logger.Panicf("number of params not equels to 2")
	}
	// 第一个参数类型固定为： *gin.Context
	if t.In(0).String() != "*gin.Context" {
		logger.Panicf("first parameter should be of type *gin.Context")
	}
	// 返回函数的返回值数量，不是func会panic
	if t.NumOut() != 2 {
		logger.Panicf("number of return values not equels to 2")
	}
	// 第二个参数类型固定为： error
	if t.Out(1).String() != "error" {
		logger.Panicf("second parameter should be of type error")
	}

	return func(c *gin.Context) {
		req := reflect.New(t.In(1).Elem()).Interface()
		// get:params、form-data post:json、xml
		if err := c.ShouldBind(req); err != nil {
			tool.Response(c, erresp.Err.WithPrompt(err.Error()))
			return
		}
		// request数据验证（验证标签：validate）
		if errStr := tool.RequestValidate(req); errStr != "" {
			tool.Response(c, erresp.Err.WithPrompt(errStr))
			return
		}

		in := []reflect.Value{
			reflect.ValueOf(c),
			reflect.ValueOf(req),
		}
		resp := v.Call(in)

		if !resp[1].IsNil() { // has err
			tool.Response(c, erresp.Parse(resp[1].Interface()))
			return
		}
		tool.Response(c, erresp.OK.WithData(resp[0].Interface()))
	}
}
