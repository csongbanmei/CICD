# 阶段 1：构建二进制
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o /app-name

# 阶段 2：最小化运行时镜像
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app-name .
EXPOSE 8080
CMD ["./app-name"]