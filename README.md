# ginc
[toc]

#### 介绍
一个基于proto配合gin的脚手架工具，
处理生成pb、tag、swagger、controller等弱代码操作。
类库列表：  
- cobra
- inject_tag
- packr
- emicklei/proto

#### 目录
```
.
├── LICENSE
├── Makefile
├── README.md
├── cmd
│   ├── client.go
│   ├── gen.go
│   ├── gen_test.go
│   ├── init.go
│   ├── root.go
│   └── version.go
├── example
│   ├── controller
│   ├── pb
│   ├── proto
│   ├── router.go
│   ├── swagger
│   └── third_party
├── gen
│   ├── controller.go
│   ├── controller_test.go
│   ├── gen-packr.go
│   ├── generator.go
│   ├── pack2.go
│   ├── proto.go
│   ├── template.go
│   └── template_test.go
├── go.mod
├── go.sum
├── main.go
├── packrd
│   └── packed-packr.go
├── template
│   ├── client
│   └── service
└── util
    ├── file.go
    ├── file_test.go
    ├── util.go
    └── util_test.go
```

#### 安装教程
1. 安装 Makefile
2. 安装 protoc
    二进制安装: https://github.com/protocolbuffers/protobuf/releases 下载,
    > mac:  protoc-3.17.3-osx-x86_64.zip
    > 解压后进入目录，拷贝相关文件到环境变量中:
    ````
     mv bin/protoc /usr/local/bin/   
     mv include/google /usr/local/include/  
    ```` 
    > windows: protoc-3.17.3-win64.zip
    > 解压复制 bin/protoc.exe 到GOBIN目录.
3. 安装 pb(golang)、swagger、tag 插件
> go get -u google.golang.org/protobuf/cmd/protoc-gen-go   
> go get -u github.com/favadi/protoc-go-inject-tag  
> go get -u gitee.com/krio/ginc  
> go get -u github.com/gobuffalo/packr/v2  
> go get -u github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2

> github.com/golang/protobuf 旧版本，具体详见： https://www.136.la/shida/show-157324.html

#### flags参数介绍
-p, --proto       proto目录: example/proto/v1   
-b, --pb          pb目录: example/pb/v1   
-w, --swagger     wagger目录: example/swagger/v1   
-t, --third_party third_party目录: example/third_party   
-c, --controller  controller目录: example/controller   
-r, --router      router路由定义文件: router/router.go  

#### 如何使用
- 如何定义一个proto
```
syntax = "proto3";

package dto.proto.v1; ---------------------------------> proto路径 【 重要 】
option go_package = "dto/pb/v1"; -----------------------> pb路径 【 重要 】 

import "google.golang.org/api/annotations.proto";

// v1/controller.go|模块名称  ---------------------------> controller文件路径 【 重要 】
service TestService { ---------------------------------> 必须带上 Service 【 重要 】
    // test -------------------------------------------> 定义接口名称备注
    rpc Test(TestReq) returns (TestResp) {
        option (google.api.http) = {
            post: "/api/v1/test"
            body: "*"
        };
    }
}

message TestReq {
    int32 id = 1;
}

message TestResp {
    string name = 1;
    int32 age = 2;
}
```

- 自定义 Tag 
```
form      请求request绑定对应结构体，推荐加上
example   swagger的字段描述  
validate  入参验证（规则参考：github.com/go-playground/validator/v10） 
label     验证字段对应描述
json      如想去掉protoc默认生成的omitempty（忽略类型）属性，重新定义即可
 
message UserAddReq {
    // @gotags: form:"phone_number" validate:"required" example:"180xxxx2021" label:"手机号"
    string phone_number = 1;
    // @gotags: form:"email" example:"emai@163.com" label:"邮箱"
    string email = 2;
    // @gotags: form:"phone_area_code" validate:"required" example:"+86" label:"手机区号"
    string phone_area_code = 3;
    // @gotags: form:"password" validate:"required"
    string password = 4;
}
```