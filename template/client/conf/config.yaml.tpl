gin:
  mode: release    # 模式：debug|release|test
  port: 8088       # 端口

logger:
  level: debug          # 错误等级： debug|info|warn|error|fatal
  debug: true           # 是否打印错误
  filePath: ./log       # 文件路径
  traceKey:             # 链路追踪keys
    - "X-Trace-Id" 

swagger:
  enable: true             # 是否开启api文档
  dir: ./dto/swagger/v1    # *.swagger.json路径

requestValidate:
  language: zh    # 请求参数验证语言：zh-中文|en-英文

grpc:
  pbAddr: localhost:8081

jwt:
  expiresTime: 10       # token过期时间(分钟)
  signKey: yyds         # token密钥
  issuer: yyds          # 签名颁发者

redis:
  dsn: localhost:6379
  password:
  maxIdle: 10
  db: 0
