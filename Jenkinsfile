pipeline {
    agent any

    environment {
        PROJECT_NAME = "cicd-demo"
        CONTAINER_NAME = "cicd-container"
        HOST_PORT = "8080"
        CONTAINER_PORT = "8080"
    }

    stages {
        stage('1. 📥 拉取代码') {
            steps {
                echo '从GitHub拉取公开代码...'
                // 直接使用公开仓库URL，无需凭证
                git url: 'https://github.com/csongbanmei/CICD.git', branch: 'main1'

                // 显示拉取的文件
                sh 'ls -la'
            }
        }

        stage('2. ⚙️ 准备环境') {
            steps {
                echo '检查并安装Go环境...'
                sh '''
                    # 检查Go是否已安装
                    if ! command -v go &> /dev/null; then
                        echo "安装Go 1.21..."
                        apt-get update
                        apt-get install -y wget tar
                        wget -q https://golang.org/dl/go1.21.4.linux-amd64.tar.gz
                        tar -C /usr/local -xzf go1.21.4.linux-amd64.tar.gz
                        export PATH=$PATH:/usr/local/go/bin
                    fi

                    # 验证环境
                    go version
                '''
            }
        }

        stage('3. 📦 安装依赖') {
            steps {
                echo '下载Go模块...'
                sh 'go mod download'
            }
        }

        stage('4. 🧪 运行测试') {
            steps {
                echo '执行单元测试...'
                sh 'go test -v ./...'
            }
        }

        stage('5. 🔨 编译应用') {
            steps {
                echo '编译Go程序...'
                sh 'CGO_ENABLED=0 GOOS=linux go build -o ${PROJECT_NAME} .'

                // 验证编译结果
                sh '''
                    echo "编译完成，文件信息:"
                    ls -lh ${PROJECT_NAME}
                    file ${PROJECT_NAME}
                '''
            }
        }

        stage('6. 🐳 构建镜像') {
            steps {
                echo '构建Docker镜像...'
                // 检查是否已有Dockerfile，如果没有则创建
                sh '''
                    if [ ! -f "Dockerfile" ]; then
                        echo "创建默认Dockerfile..."
                        cat > Dockerfile << 'EOF'
FROM alpine:3.14
WORKDIR /app
COPY cicd-demo .
RUN chmod +x cicd-demo
EXPOSE 8080
CMD ["./cicd-demo"]
EOF
                    fi

                    # 显示Dockerfile内容
                    echo "Dockerfile内容:"
                    cat Dockerfile

                    # 构建镜像
                    docker build -t ${PROJECT_NAME}:latest .

                    echo "镜像构建完成:"
                    docker images | grep ${PROJECT_NAME}
                '''
            }
        }

        stage('7. 🛑 清理旧容器') {
            steps {
                echo '清理旧版本容器...'
                sh '''
                    # 停止并删除旧容器（如果存在）
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    echo "旧容器清理完成"
                '''
            }
        }

        stage('8. 🚀 部署应用') {
            steps {
                echo '启动新容器...'
                sh """
                    docker run -d \\
                        --name ${CONTAINER_NAME} \\
                        --restart unless-stopped \\
                        -p ${HOST_PORT}:${CONTAINER_PORT} \\
                        ${PROJECT_NAME}:latest

                    echo "新容器已启动"
                """
            }
        }

        stage('9. ✅ 验证部署') {
            steps {
                echo '检查部署状态...'
                script {
                    // 等待应用启动
                    sleep 8

                    sh '''
                        echo "=== 容器状态 ==="
                        docker ps --filter "name=${CONTAINER_NAME}"

                        echo "=== 应用日志 ==="
                        docker logs ${CONTAINER_NAME} --tail 10

                        echo "=== 测试访问 ==="
                        curl -s -o /dev/null -w "HTTP状态码: %{http_code}\n" http://localhost:${HOST_PORT} || echo "应用正在启动中..."
                    '''
                }
            }
        }
    }

    post {
        always {
            echo '流水线执行完成'
            // 显示最终状态
            sh '''
                echo "=== 最终容器列表 ==="
                docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

                echo "=== 最终镜像列表 ==="
                docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
            '''
        }
        success {
            echo '🎉 部署成功！'
            echo "🌐 访问地址: http://你的服务器IP:${HOST_PORT}"
        }
        failure {
            echo '❌ 部署失败'
            echo '请查看控制台输出排查问题'
        }
    }
}