syntax = "proto3";

package dto.proto.v1;
option go_package = "dto/pb/v1";

import "google/api/annotations.proto";
import "public_api.proto";


// v1/example.go
service ExampleService {
    // 列表
    rpc ListExample(ListExampleReq) returns (ListExampleResp) {
        option (google.api.http) = {
            get: "/api/v1/example/list"
        };
    }
    // 新增
    rpc AddExample(AddExampleReq) returns (ID) {
        option (google.api.http) = {
            post: "/api/v1/example/add"
            body: "*"
        };
    }
    // 修改
    rpc UpdateExample(UpdateExampleReq) returns (ID) {
        option (google.api.http) = {
            put: "/api/v1/example/update"
            body: "*"
        };
    }
    // 详情
    rpc DetailExample(ID) returns (DetailExampleResp) {
        option (google.api.http) = {
            get: "/api/v1/example/detail"
        };
    }
    // 删除
    rpc DeleteExample(ID) returns (EmptyResponse) {
        option (google.api.http) = {
            delete: "/api/v1/example/delete"
        };
    }
}

message ListExampleReq {
        // @gotags: form:"page_index" example:"1"
        int32 page_index = 1;
        // @gotags: form:"page_size" example:"10"
        int32 page_size = 2;
        // @gotags: form:"keyword" example:"张三"
        string keyword = 3;
}

message ListExampleResp {
    int32 page_total = 1;
    repeated One data = 2;
    message One {
        int32 id = 1;
        string name = 2;
        int32 age = 3;
    }
}

message AddExampleReq {
    string name = 1;
    uint32 age = 2;
}

message UpdateExampleReq {
    int32 id = 1;
    string name = 2;
    uint32 age = 3;
}

message DetailExampleResp {
    int32 id = 1;
    string name = 2;
    uint32 age = 3;
}