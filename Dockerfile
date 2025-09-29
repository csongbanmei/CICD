# 多阶段构建
# 构建阶段
FROM golang:1.21-alpine AS builder

# 设置工作目录
WORKDIR /app

# 复制依赖文件并下载依赖（利用Docker缓存）
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY . .

# 构建应用（禁用CGO，减小体积）
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o Test-CICD main.go router.go

# 运行阶段 - 使用更小的基础镜像
FROM alpine:3.18

# 安装CA证书（用于HTTPS请求）
RUN apk --no-cache add ca-certificates tzdata && \
    update-ca-certificates && \
    # 创建非root用户
    addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -D appuser

# 设置工作目录
WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder --chown=appuser:appuser /app/Test-CICD .

# 切换到非root用户
USER appuser

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# 启动应用
CMD ["./Test-CICD"]
