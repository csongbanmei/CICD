# 阶段1：构建（使用完整 Go 环境）
FROM golang:1.21-alpine AS builder
WORKDIR /app
# 优先复制依赖文件，利用 Docker 缓存加速构建
COPY go.mod go.sum ./
RUN go mod download
# 复制源码并编译（优化二进制体积）
COPY . .
RUN go build -ldflags="-s -w" -o main .

# 阶段2：运行（使用轻量镜像）
FROM alpine:latest
WORKDIR /app
# 从构建阶段复制二进制文件
COPY --from=builder /app/main .
# 创建非 root 用户（提升安全性）
RUN adduser -D -S appuser && chown appuser:appuser main
USER appuser
# 暴露端口并启动应用
EXPOSE 8080
CMD ["./main"]