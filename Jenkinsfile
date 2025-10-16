pipeline {
    agent any

    environment {
        APP_NAME = "my-go-app"
        IMAGE_TAG = "${APP_NAME}:${BUILD_ID}"
    }

    stages {
        // 1️⃣ 拉取代码
        stage('Checkout') {
            steps {
                echo "📥 拉取代码..."
                checkout scm
            }
        }

        // 2️⃣ 构建 Docker 镜像（并在 builder 阶段跑单元测试）
        stage('Build Image') {
            steps {
                script {
                    echo "🚧 开始构建镜像并运行测试..."
                    // 禁用 BuildKit 避免 Jenkins 容器报错
                    sh '''
                    DOCKER_BUILDKIT=0 docker build -t ${IMAGE_TAG} --progress=plain -f Dockerfile .
                    '''
                }
            }
        }

        // 3️⃣ 部署阶段
        stage('Deploy') {
            steps {
                script {
                    echo "🚀 开始部署应用..."
                    // 停止旧容器
                    sh 'docker stop go-app || true'
                    sh 'docker rm go-app || true'

                    // 启动新容器
                    sh "docker run -d --name go-app -p 8080:8080 ${IMAGE_TAG}"

                    // 清理旧镜像（24h以前的）
                    sh 'docker image prune -f --filter "until=24h"'
                }
            }
        }
    }

    // ✅ 构建后操作
    post {
        success {
            echo "✅ 部署成功！访问地址：http://<你的服务器IP>:8080"
        }
        failure {
            echo "❌ 构建失败！请检查日志：${env.BUILD_URL}console"
        }
    }
}
