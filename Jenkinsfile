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
                checkout scm
            }
        }

        // 2️⃣ 构建 Docker 镜像
        stage('Build Image') {
            steps {
                script {
                    // 使用项目根目录的 Dockerfile 构建镜像
                    sh '''
                    echo "🚧 开始构建镜像..."
                    DOCKER_BUILDKIT=1 docker build -t ${IMAGE_TAG} .
                    '''
                }
            }
        }

        // 3️⃣ 在容器中运行单元测试
        stage('Test') {
            steps {
                script {
                    // 使用刚构建的镜像执行测试，保证测试环境一致
                    sh '''
                    echo "🧪 运行单元测试..."
                    docker run --rm ${IMAGE_TAG} go test -v ./... || exit 1
                    '''
                }
            }
        }

        // 4️⃣ 部署阶段
        stage('Deploy') {
            steps {
                script {
                    echo "🚀 开始部署应用..."
                    // 停止旧容器
                    sh 'docker stop go-app || true'
                    sh 'docker rm go-app || true'

                    // 启动新容器
                    sh 'docker run -d --name go-app -p 8080:8080 ${IMAGE_TAG}'

                    // 清理旧镜像
                    sh 'docker image prune -f --filter "until=24h"'
                }
            }
        }
    }

    // ✅ 构建后操作
    post {
        success {
            echo "✅ 部署成功！访问地址：http://${env.BUILD_URL}"
        }
        failure {
            echo "❌ 构建失败！请检查日志：${env.BUILD_URL}console"
        }
    }
}
