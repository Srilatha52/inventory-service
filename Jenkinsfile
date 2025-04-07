pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'inventory-service-container'
        WORKSPACE_UNIX = '/c/Users/srila/.jenkins/workspace/Inventory-service-main'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Srilatha52/inventory-service.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Build & Test in Docker') {
            steps {
                script {
                    sh """
                        docker run --rm \
                        -v ${WORKSPACE_UNIX}:${WORKSPACE_UNIX} \
                        -w ${WORKSPACE_UNIX} \
                        ${DOCKER_IMAGE} mvn clean verify
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

        stage('Code Analysis with SonarQube') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                    sh """
                        docker run --rm \
                        -e SONAR_HOST_URL=http://host.docker.internal:9000 \
                        -e SONAR_TOKEN=$SONAR_TOKEN \
                        -v ${WORKSPACE_UNIX}:${WORKSPACE_UNIX} \
                        -w ${WORKSPACE_UNIX} \
                        ${DOCKER_IMAGE} mvn sonar:sonar
                    """
                }
            }
        }

        stage('Deploy with Ansible (WSL)') {
            steps {
                bat 'wsl bash -c "cd ~/inventory-service-main && ansible-playbook -i inventory/localhost.yml deploy.yml"'
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
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
