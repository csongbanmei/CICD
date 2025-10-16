# Dockerfile
FROM golang:1.24.2-alpine AS builder
WORKDIR /app
ENV GOPROXY=https://goproxy.cn,direct
ENV GOSUMDB=off

COPY go.mod go.sum ./
RUN go mod download
COPY . .

# ✅ 在构建阶段运行单元测试
RUN go test -v ./...

# 编译可执行文件
RUN go build -ldflags="-s -w" -o main .

# 最终生产镜像只带 main
FROM alpine:latest
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
