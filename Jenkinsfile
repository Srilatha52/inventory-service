pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'inventory-service-container'
        SONAR_URL = 'http://host.docker.internal:9000'
        SONAR_TOKEN = credentials('sonarqube-token') // Replace this with the correct Jenkins credential ID
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Srilatha52/inventory-service.git'
            }
        }

        stage('Build & Test in Docker') {
            steps {
                script {
                    def windowsPath = "${env.WORKSPACE}".replace('\\', '/')
                    def unixPath = windowsPath.replaceFirst(/^([A-Za-z]):/, '/$1')  // correct case

                    echo "✅ Unix Path for Docker: ${unixPath}"

                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE} ."

                    // Run tests and generate coverage
                    sh """
                        docker run --rm \
                        -v ${unixPath}:${unixPath} \
                        -w ${unixPath} \
                        ${DOCKER_IMAGE} mvn clean verify
                    """
                }
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target/site/jacoco',
                        reportFiles: 'index.html',
                        reportName: 'JaCoCo Coverage Report'
                    ])
                }
            }
        }

        stage('Code Analysis with SonarQube') {
            steps {
                script {
                    def windowsPath = "${env.WORKSPACE}".replace('\\', '/')
                    def unixPath = windowsPath.replaceFirst(/^([A-Za-z]):/, '/$1')

                    sh """
                        docker run --rm \
                        -e SONAR_HOST_URL=${SONAR_URL} \
                        -e SONAR_TOKEN=${SONAR_TOKEN} \
                        -v ${unixPath}:${unixPath} \
                        -w ${unixPath} \
                        ${DOCKER_IMAGE} mvn sonar:sonar
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t inventory-service:latest ."
            }
        }

        stage('Deploy with Ansible (WSL)') {
            steps {
                bat 'wsl sh -c "cd ~/inventory-service-main && ansible-playbook -i inventory/localhost.yml deploy.yml"'
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'curl -f http://localhost:8082/api/inventory || exit 1'
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
        }
        success {
            echo ' Deployment successful!'
        }
        failure {
            echo ' Deployment failed.'
        }
    }
}
