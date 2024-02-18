.PHONY:lint
lint:
	golangci-lint run 

.PHONY:init
init:
	go run . init

.PHONY:version
version:
	go run . version

.PHONY:packr2
packr2:
	packr2 clean && packr2

.PHONY:client
client:
	go run . client -n demo -m demo

.PHONY: all
all: 
	go run . gen -p example/proto/v1 -b example/pb/v1 -w example/swagger/v1 -t example/third_party -c example/controller 
	#go run . gen -p example/proto/v2 -b example/pb/v2 -w example/swagger/v2 -t example/third_party -c example/controller


export TagName := v1.3.4
.PHONY: gitag
gitag:
	git add . && git commit -m "$(TagName)"
	git push
	git tag -a $(TagName) -m "$(TagName)" # 创建带标签的Tag
	git push origin $(TagName)  # 推送Tag到远程