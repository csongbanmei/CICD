# Builder 阶段：构建可执行文件并运行测试
FROM golang:1.24.2-alpine AS builder

WORKDIR /app

# 设置 Go 代理和关闭校验
ENV GOPROXY=https://goproxy.cn,direct
ENV GOSUMDB=off

# 拷贝依赖文件并下载依赖
COPY go.mod go.sum ./
RUN go mod download

# 拷贝项目代码
COPY . .

# 运行单元测试
RUN go test -v ./...

# 构建可执行文件
RUN go build -ldflags="-s -w" -o main .

# 生产阶段：仅包含可执行文件和证书
FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache ca-certificates

# 拷贝 Builder 阶段生成的可执行文件
COPY --from=builder /app/main .

# 暴露端口
EXPOSE 8080

# 启动命令
CMD ["./main"]
