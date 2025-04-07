pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'inventory-service-container'  // Image name for the container
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
                    // Build the Docker image if not already built
                    sh """
                        docker build -t ${DOCKER_IMAGE} .
                    """
                    // Run the container and execute build and test commands
                    sh """
                        docker run --rm ${DOCKER_IMAGE} mvn clean package
                        docker run --rm ${DOCKER_IMAGE} mvn test
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
            steps {
                script {
                    // Run SonarQube analysis inside Docker container
                    sh """
                        docker run --rm ${DOCKER_IMAGE} mvn sonar:sonar
                    """
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image for the service
                    sh """
                        docker build -t inventory-service:latest .
                    """
                }
            }
        }
        stage('Deploy with Ansible') {
            steps {
                script {
                    // Assuming Docker container has Ansible installed, or running Ansible inside a separate container
                    sh """
                        docker run --rm -v /path/to/ansible-playbook:/app ${DOCKER_IMAGE} ansible-playbook -i inventory/localhost.yml deploy.yml
                    """
                }
            }
        }
        stage('Verify Deployment') {
            steps {
                script {
                    sh """
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