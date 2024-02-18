package tool

import (
	"reflect"
	"strings"

	"{{.ProjectModule}}/conf"

	"gitee.com/krio/helper/logger"
	"github.com/go-playground/locales"
	en "github.com/go-playground/locales/en"
	zh_cn "github.com/go-playground/locales/zh"
	ut "github.com/go-playground/universal-translator"
	"github.com/go-playground/validator/v10"
	en_translations "github.com/go-playground/validator/v10/translations/en"
	zh_translations "github.com/go-playground/validator/v10/translations/zh"
)

var (
	validate *validator.Validate
	trans    ut.Translator
)

// api入参验证
func init() {
	var (
		uni  *ut.UniversalTranslator
		lt   locales.Translator
		err  error
		lang string
	)

	validate = validator.New()
	// 获取struct tag里自定义的label作为字段名
	validate.RegisterTagNameFunc(func(field reflect.StructField) string {
		label := field.Tag.Get("label")
		if label == "" {
			return field.Name
		}
		return label
	})

	// 语言选择
	lang = conf.C.RequestValidate.Language
	switch lang {
	case "zh":
		lt = zh_cn.New()
		uni = ut.New(lt, lt)
		trans, _ = uni.GetTranslator(lang)
		// 注册翻译器
		err = zh_translations.RegisterDefaultTranslations(validate, trans)
	case "en":
		lt = en.New()
		uni = ut.New(lt, lt)
		trans, _ = uni.GetTranslator(lang)
		// 注册翻译器
		err = en_translations.RegisterDefaultTranslations(validate, trans)
	}
	if err != nil {
		logger.Fatal(err)
	}
}

// 错误返回
func translate(err error) string {
	var errList []string
	for _, e := range err.(validator.ValidationErrors) {
		// can translate each error one at a time.
		errList = append(errList, e.Translate(trans))
	}

	return strings.Join(errList, "|")
}

func RequestValidate(req interface{}) string {
	if err := validate.Struct(req); err != nil {
		return translate(err)
	}

	return ""
}
