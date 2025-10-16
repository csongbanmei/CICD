pipeline {
    agent any
    environment {
        APP_NAME = "my-go-app"
        // 动态镜像标签（避免覆盖）
        IMAGE_TAG = "${APP_NAME}:${env.BUILD_ID}"
    }
    stages {
        // 1. 拉取代码
        stage('Checkout') {
            steps {
                checkout scm  // 自动拉取 Git 仓库代码
            }
        }

        // 2. 构建 Docker 镜像
        stage('Build Image') {
            steps {
                script {
                    // 使用项目中的 Dockerfile 构建镜像
                    docker.build("${IMAGE_TAG}")
                }
            }
        }

        // 3. 运行单元测试（Go 项目专用）
        stage('Test') {
            steps {
                sh 'go test -v ./...'  // 运行所有单元测试[6](@ref)
            }
        }

        // 4. 部署到云服务器
        stage('Deploy') {
            steps {
                script {
                    // 停止并删除旧容器（忽略错误）
                    sh 'docker stop go-app || true'
                    sh 'docker rm go-app || true'
                    // 启动新容器（映射端口 8080）
                    docker.run(
                        "-d --name go-app -p 8080:8080 ${IMAGE_TAG}"
                    )
                    // 清理旧镜像（避免磁盘占满）
                    sh 'docker image prune -f --filter "until=24h"'
                }
            }
        }
    }
    // 构建后通知
    post {
        success {
            echo '✅ 部署成功！访问地址：http://<你的服务器IP>:8080'
        }
        failure {
            echo '❌ 构建失败！检查日志：${env.BUILD_URL}console'
        }
    }
}