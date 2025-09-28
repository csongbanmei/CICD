pipeline {
    agent any

    environment {
        GO111MODULE = "on"
        GOPROXY = "https://goproxy.cn,direct"
        APP_NAME = "Test-CICD"
        IMAGE_NAME = "Test-CICD"
        CONTAINER_NAME = "Test-CICD-container"
        HOST_PORT = "8080"
        CONTAINER_PORT = "8080"
    }

    stages {
        stage('代码检出') {
            steps {
                git branch: 'main',
                    url: 'https://github.acme.red/chenchiyuan/Test-CICD.git'
            }
        }

        stage('依赖安装') {
            steps {
                sh 'go mod download'
                sh 'go mod verify'
            }
        }

        stage('代码检查') {
            steps {
                sh 'go vet ./...'
                sh 'go fmt ./...'
            }
        }

        stage('单元测试') {
            steps {
                sh 'go test -v ./... -coverprofile=coverage.out'
            }
            post {
                always {
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

        stage('编译构建') {
            steps {
                sh 'go build -o ${APP_NAME} main.go router.go'
                sh 'ls -la'
            }
        }

        stage('Docker 镜像构建') {
            steps {
                script {
                    def image = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('部署测试') {
            steps {
                sh '''
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true
                docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${IMAGE_NAME}:${env.BUILD_NUMBER}
                '''
            }
        }

        stage('健康检查') {
            steps {
                sh 'sleep 10'
                sh 'curl -f http://localhost:${HOST_PORT}/health || exit 1'
            }
        }
    }

    post {
        success {
            echo '🎉 CI/CD 流水线执行成功！'
            emailext (
                subject: "✅ BUILD SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "构建详情: ${env.BUILD_URL}",
                to: "your-email@example.com"
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
        always {
            // 清理工作
            sh 'docker system prune -f || true'
        }
    }
}