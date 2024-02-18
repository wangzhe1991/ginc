# *************************************** [ 项目Makefile配置 ] ***************************************

# 定义环境变量
export GOBIN  := $(CURDIR)/bin

# 代码风格检查
.PHONY: lint
lint:
	@echo "*** golangci-lint"
	@golangci-lint run

# 单元测试
.PHONY: test
test:
	@echo "*** go test"
	@gotest -v ./... || go test -v ./...

# 运行
.PHONY: run
run:
	@go run main.go

# api生成工具: gpgc 
.PHONY: gpgc
gpgc: 
	@gpgc gen \
	@echo "*** gpgc gen"

# 生成可执行文件
.PHONY: build
build:
	@echo "*** go build"
	go mod tidy
	go build -o  $(GOBIN)/{{.ProjectName}} 

# 清除本地生成的可执行文件
.PHONY: clean
clean:
	@echo "*** clean bin/*"
ifeq ($(OS),Windows_NT)
	@ del bin/*
else
	@rm -rf bin/*
endif

# 自定义综合命令
.PHONY: all
all:
	make build
	make lint
	make clean