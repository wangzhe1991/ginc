# golangci-lint配置 
# 详见：https://golangci-lint.run/usage/linters

service: # 版本
  golangci-lint-version: 1.17 # 指定版本 use the fixed version to not introduce new linters unexpectedly

run: # 运行配置
  concurrency: 4 # 要使用的CPU核心数
  timeout: 5m # 分析超时，例如 30s, 5m，默认是 1m
  modules-download-mode: readonly # 包管理模式，go modules使用readonly，可用的值范围 readonly|release|vendor
  issues-exit-code: 10 # 当有多少个问题存在时则退出检查，默认是1
  tests: true # 是否包含测试文件
  skip-dirs-use-default: true # 允许跳过目录
  skip-dirs: # 要跳过检查的目录
    - bin
    - vendor
  skip-files: # 跳过文件


output: # 输出配置
  format: colored-line-number # colored-line-number|line-number|json|tab|checkstyle|code-climate, default is "colored-line-number"
  print-issued-lines: true # 打印行号
  print-linter-name: true # 打印检查器的名称

linters-settings: # 质量检查配置
  errcheck:  # 错误检查
    check-type-assertions: false # 检查类型错误
    check-blank: true # 检查空标识符
    ignore: fmt:.*,io/ioutil:^Read.* # 忽略文件

  funlen: # 用于检测长函数的工具
    lines: 60 # 行数
    statements: 40 # 声明数量

  govet:
    check-shadowing: true # 检查幽灵变量（变量覆盖）问题
    # 按名称启用或禁用分析器
    # run `go tool vet help` to see all analyzers
    enable-all: false
    enable:
      # - fieldalignment # 内存对齐优化
      - atomicalign
    disable-all: false
    disable:
      - shadow

  golint:
    min-confidence: 0.8 # minimal confidence for issues, default is 0.8

  gocyclo: # 检查函数的复杂程度
    min-complexity: 35 # 最小复杂性

  gocognit:
    min-complexity: 35  # 最小复杂性

  maligned:
    suggest-new: true # 为内存对齐优化给出新的结构体字段排序建议
    auto-fix: true # 自动修复

  misspell: # Finds commonly misspelled English words in comments
    # Correct spellings using locale preferences for US or UK.
    # Default is to use a neutral variety of English.
    # Setting locale to US will correct the British spelling of 'colour' to 'color'.
    locale: US
    ignore-words:
      - someword

  nakedret:
    max-func-lines: 30  # 如果func的代码行数比这个设置的多，并且它的返回值是空的，就会产生问题，默认是30

  unparam:
    # Inspect exported functions, default is false. Set to true if no external program/library imports your code.
    # XXX: if you enable this setting, unparam will report a lot of false-positives in text editors:
    # if it's called for subdir of a project it can't find external interfaces. All text editor integrations
    # with golangci-lint call it on a directory with the changed file.
    check-exported: false


linters:
  enable:
    - deadcode #[默认启用] 未使用且未导出的函数(比如：首字母小写且未被调用的方法) Finds unused code 
    - errcheck #[默认启用] Errcheck is a program for checking for unchecked errors in go programs. These unchecked errors can be critical bugs in some cases 返回的error未处理
    - gosimple #[默认启用] 代码中有需要优化的地方
    - govet #[默认启用] Vet检查Go源代码并报告可疑结构 Vet examines Go source code and reports suspicious constructs, such as Printf calls whose arguments do not align with the format string
    - ineffassign #[默认启用] 检测变量的赋值
    - staticcheck #[默认启用] 静态分析检查 Staticcheck is a go vet on steroids, applying a ton of static analysis checks
    - structcheck #[默认启用] 检测结构体中未使用的字段 Finds unused struct fields
    - typecheck #[默认启用] 类型检查 Like the front-end of a Go compiler, parses and type-checks Go code
    - unused #[默认启用] Checks Go code for unused constants, variables, functions and types
    - varcheck #[默认启用] 查找未使用的全局变量和常量 Finds unused global variables and constants
    - depguard # 检查包导入是否在可接受包的列表中 Go linter that checks if package imports are in a list of acceptable packages
    - dogsled #  Checks assignments with too many blank identifiers (e.g. x, , , _, := f())
    - goconst # 查找可由常量替换的重复字符串 Finds repeated strings that could be replaced by a constant
    - gocyclo # Computes and checks the cyclomatic complexity of functions
    - unconvert # 删除不必要的类型转换 Remove unnecessary type conversions
    - unparam # 报告未使用的函数参数 Reports unused function parameters
    - nestif # Reports deeply nested if statements
    - gofmt # Gofmt checks whether code was gofmt-ed. By default this tool runs with -s option to check for code simplification
    - misspell # 在注释中查找拼写错误的英语单词 Finds commonly misspelled English words in comments
  enable-all: false
  disable:
    - maligned # 内存对齐优化 The repository of the linter has been archived by the owner. Replaced by govet 'fieldalignment'.
    - gosec # Inspects source code for security problems
    - nilerr # Finds the code that returns nil even if it checks that the error is not nil.
    - bodyclose # 检查HTTP响应正文是否已成功关闭 checks whether HTTP response body is closed successfully
    - godox # 用于检测FIXME、TODO和其他注释关键字的工具 Tool for detection of FIXME, TODO and other comment keywords
    - goimports
    - interfacer
    - scopelint
    - gosec
    - errorlint
    - gocritic
    - gochecknoinits
    - stylecheck
    - funlen
    - whitespace
    - dupl
    - golint
    - lll
    - wsl
    - nakedret # Finds commonly misspelled English words in comments
    - gochecknoglobals
  disable-all: false
  presets:
    - bugs
    - unused
  fast: false
