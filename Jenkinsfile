pipeline {
    agent any

    environment {
        APP_NAME = "my-go-app"
        IMAGE_TAG = "${APP_NAME}:${BUILD_ID}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "📥 拉取代码..."
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                script {
                    echo "🚧 开始构建镜像..."
                    // 禁用 BuildKit，避免 Jenkins 报错
                    sh '''
                    DOCKER_BUILDKIT=0 docker build -t ${IMAGE_TAG} -f Dockerfile .
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "🚀 开始部署应用..."
                    // 停止旧容器
                    sh 'docker stop go-app || true'
                    sh 'docker rm go-app || true'

                    // 启动新容器
                    sh "docker run -d --name go-app -p 8080:8080 ${IMAGE_TAG}"

                    // 清理旧镜像
                    sh 'docker image prune -f --filter "until=24h"'
                }
            }
        }
    }

    post {
        success {
            echo "✅ 部署成功！访问地址：http://<你的服务器IP>:8080"
        }
        failure {
            echo "❌ 构建失败！请检查日志：${env.BUILD_URL}console"
        }
    }
}
