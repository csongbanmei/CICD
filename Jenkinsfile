pipeline {
    agent any

    environment {
        APP_NAME = "my-go-app"
        IMAGE_TAG = "${APP_NAME}:${BUILD_ID}"  // 动态镜像标签，避免覆盖
    }

    stages {
        // 1️⃣ 拉取代码
        stage('Checkout') {
            steps {
                echo "📥 拉取代码..."
                checkout scm
            }
        }

        // 2️⃣ 构建 Docker 镜像（禁用 BuildKit）
        stage('Build Image') {
            steps {
                script {
                    echo "🚧 开始构建镜像..."
                    sh '''
                    DOCKER_BUILDKIT=0 docker build -t ${IMAGE_TAG} .
                    '''
                }
            }
        }

        // 3️⃣ 运行单元测试（在容器内运行）
        stage('Test') {
            steps {
                script {
                    echo "🧪 运行单元测试..."
                    sh '''
                    docker run --rm ${IMAGE_TAG} go test -v ./... || exit 1
                    '''
                }
            }
        }

        // 4️⃣ 部署到云服务器
        stage('Deploy') {
            steps {
                script {
                    echo "🚀 开始部署应用..."
                    # 停止旧容器
                    sh 'docker stop go-app || true'
                    sh 'docker rm go-app || true'

                    # 启动新容器
                    sh 'docker run -d --name go-app -p 8080:8080 ${IMAGE_TAG}'

                    # 清理旧镜像，避免磁盘占满
                    sh 'docker image prune -f --filter "until=24h"'
                }
            }
        }
    }

    // 构建后通知
    post {
        success {
            echo "✅ 部署成功！访问地址：http://<你的服务器IP>:8080"
        }
        failure {
            echo "❌ 构建失败！请检查日志：${env.BUILD_URL}console"
        }
    }
}
