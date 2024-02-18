syntax = "proto3";

package dto.proto.v1;
option go_package = "dto/pb/v1";

import "protoc-gen-swagger/options/annotations.proto";

// 定义概要[首页] (注意：这个文件必要)
option (grpc.gateway.protoc_gen_swagger.options.openapiv2_swagger) = {
    info: {
        title: "haha";
        version : "v1";
        description: "";
    };
};