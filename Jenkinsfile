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

        stage('Build & Test') {
            steps {
                script {
                    echo "🚧 构建镜像并在 Builder 阶段跑测试..."
                    sh '''
                    DOCKER_BUILDKIT=0 docker build -t ${IMAGE_TAG} -f Dockerfile .
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "🚀 部署应用..."

                    // 停止并删除旧容器（存在就删除）
                    sh '''
                    if [ $(docker ps -aq -f name=go-app) ]; then
                        docker rm -f go-app
                    fi
                    '''

                    // 启动新容器，宿主机端口 8081 映射到容器 8080
                    sh "docker run -d --name go-app -p 8081:8080 ${IMAGE_TAG}"

                    // 清理旧镜像
                    sh 'docker image prune -f --filter "until=24h"'
                }
            }
        }
    }

    post {
        success {
            echo "✅ 部署成功！访问地址：http://<你的服务器IP>:8081"
        }
        failure {
            echo "❌ 构建失败！请检查日志：${env.BUILD_URL}console"
        }
    }
}
