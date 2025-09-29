pipeline {
    agent any

    environment {
        // Go 环境配置
        GO111MODULE = "on"
        GOPROXY = "https://goproxy.cn,direct"

        // 应用配置
        APP_NAME = "Test-CICD"
        IMAGE_NAME = "test-cicd"  // Docker 镜像名使用小写
        CONTAINER_NAME = "test-cicd-container"
        HOST_PORT = "8081"       // 使用 8081 端口避免冲突
        CONTAINER_PORT = "8080"

        // 构建信息
        BUILD_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0, 7)}"
    }

    stages {
        // 代码检出阶段
        stage('代码检出') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-csongbanmei-cicd',
                    url: 'https://github.com/csongbanmei/Test-CICD.git'
                sh 'echo "代码检出完成，当前提交: ${GIT_COMMIT}"'
            }
        }

        // 依赖管理阶段
        stage('依赖安装') {
            steps {
                sh 'go mod download'
                sh 'go mod verify'
                sh 'go mod tidy'
            }
        }

        // 代码质量检查
        stage('代码检查') {
            steps {
                sh 'go vet ./...'
                sh 'go fmt ./...'
                sh 'echo "代码检查完成"'
            }
        }

        // 单元测试
        stage('单元测试') {
            steps {
                sh 'go test -v ./... -coverprofile=coverage.out -covermode=atomic'
            }
            post {
                always {
                    // 生成覆盖率报告
                    sh 'go tool cover -func=coverage.out'
                    sh 'go tool cover -html=coverage.out -o coverage.html'
                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: '.',
                        reportFiles: 'coverage.html',
                        reportName: '代码覆盖率报告'
                    ])
                }
            }
        }

        // 编译构建
        stage('编译构建') {
            steps {
                sh 'go build -ldflags="-w -s" -o ${APP_NAME} main.go router.go'
                sh 'ls -la && ./${APP_NAME} --version || true'
                // 归档构建产物
                archiveArtifacts artifacts: '${APP_NAME}', fingerprint: true
            }
        }

        // Docker 镜像构建
        stage('Docker 镜像构建') {
            steps {
                script {
                    // 构建 Docker 镜像
                    sh """
                    docker build -t ${IMAGE_NAME}:${BUILD_TAG} .
                    docker tag ${IMAGE_NAME}:${BUILD_TAG} ${IMAGE_NAME}:latest
                    """

                    // 显示镜像信息
                    sh 'docker images | grep ${IMAGE_NAME}'
                }
            }
        }

        // 部署测试
        stage('部署测试') {
            steps {
                script {
                    // 清理旧容器
                    sh 'docker stop ${CONTAINER_NAME} || true'
                    sh 'docker rm ${CONTAINER_NAME} || true'

                    // 运行新容器
                    sh """
                    docker run -d \\
                        --name ${CONTAINER_NAME} \\
                        -p ${HOST_PORT}:${CONTAINER_PORT} \\
                        --health-cmd="curl -f http://localhost:${CONTAINER_PORT}/health || exit 1" \\
                        --health-interval=10s \\
                        --health-timeout=3s \\
                        --health-retries=3 \\
                        ${IMAGE_NAME}:latest
                    """

                    echo "容器已启动，访问地址: http://localhost:${HOST_PORT}"
                }
            }
        }

        // 健康检查
        stage('健康检查') {
            steps {
                retry(3) {
                    script {
                        // 等待容器健康状态
                        waitUntil {
                            def healthStatus = sh(
                                script: 'docker inspect --format "{{.State.Health.Status}}" ${CONTAINER_NAME}',
                                returnStdout: true
                            ).trim()
                            return healthStatus == 'healthy'
                        }

                        // 测试应用接口
                        sh 'curl -s http://localhost:${HOST_PORT}/health'
                        sh 'curl -s http://localhost:${HOST_PORT} | head -5'
                    }
                }
                echo "✅ 应用健康检查通过"
            }
        }
    }

    post {
        always {
            echo "构建完成，清理环境..."
            script {
                // 清理容器
                sh 'docker stop ${CONTAINER_NAME} || true'
                sh 'docker rm ${CONTAINER_NAME} || true'

                // 清理中间镜像，保留最新镜像
                sh 'docker images --filter "dangling=true" -q | xargs -r docker rmi || true'

                // 显示磁盘使用情况
                sh 'docker system df'
            }
        }

        success {
            echo '🎉 CI/CD 流水线执行成功！'
            // 邮件通知配置
            emailext (
                subject: "✅ BUILD SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                构建详情: ${env.BUILD_URL}
                应用地址: http://localhost:${HOST_PORT}
                镜像标签: ${IMAGE_NAME}:${BUILD_TAG}
                """,
                to: "2405933595@qq.com"
            )
        }

        failure {
            echo '❌ CI/CD 流水线执行失败！'
            emailext (
                subject: "❌ BUILD FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "失败详情: ${env.BUILD_URL}",
                to: "2405933595@qq.com"
            )
        }
    }
}