pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'inventory-service-container'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Srilatha52/inventory-service.git'
            }
        }

        stage('Build and Test in Docker') {
            steps {
                script {
                    def unixWorkspace = WORKSPACE.replace('\\', '/').replace('C:', '/c')
                    bat "docker build -t ${DOCKER_IMAGE} ."
                    bat """
                        docker run --rm ^
                            -v "${unixWorkspace}:${unixWorkspace}" ^
                            -w "${unixWorkspace}" ^
                            ${DOCKER_IMAGE} ^
                            mvn clean verify
                    """
                }
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    publishHTML(target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'target/site/jacoco',
                        reportFiles: 'index.html',
                        reportName: 'JaCoCo Report'
                    ])
                }
            }
        }

        stage('Code Analysis') {
            environment {
                SONAR_TOKEN = credentials('SONAR_TOKEN')
            }
            steps {
                script {
                    def unixWorkspace = WORKSPACE.replace('\\', '/').replace('C:', '/c')
                    bat """
                        docker run --rm ^
                            -v "${unixWorkspace}:${unixWorkspace}" ^
                            -w "${unixWorkspace}" ^
                            -e SONAR_HOST_URL=http://host.docker.internal:9000 ^
                            -e SONAR_TOKEN=${SONAR_TOKEN} ^
                            ${DOCKER_IMAGE} ^
                            mvn verify sonar:sonar ^
                            -Dsonar.token=${SONAR_TOKEN} ^
                            -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker build -t inventory-service:latest ."
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                script {
                    // Running directly in WSL using Ubuntu where Ansible & Docker are installed
                    bat 'wsl bash -c "cd /mnt/d/inventory-service-main && ansible-playbook -i inventory/localhost.yml deploy.yml"'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    bat """
                        docker run --rm ${DOCKER_IMAGE} curl -f http://localhost:8080/api/inventory || exit 1
                    """
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
