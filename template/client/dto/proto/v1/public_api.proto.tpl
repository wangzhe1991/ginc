syntax = "proto3";

package dto.proto.v1;
option go_package = "dto/pb/v1";


message EmptyRequest {
}

message EmptyResponse {
}

message ID {
    int32 id = 1;
}

message IDs {
    repeated int32 ids = 1;
}

message IndexRequest {
    // @gotags: form:"page_index" example:"1"
    int32 page_index = 1;
    // @gotags: form:"page_size" example:"10"
    int32 page_size = 2;
    // @gotags: form:"keyword" example:"张三"
    string keyword = 3;
}

message ExprotResponse {
    string title = 1;
    string path = 2;
    string file = 3;
}