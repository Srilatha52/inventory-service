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
                    // Build the Docker image
                    sh """
                        docker build -t ${DOCKER_IMAGE} .
                    """

                    // Run tests and mount workspace to preserve results
                    sh """
                        docker run --rm -v $WORKSPACE:/app -w /app ${DOCKER_IMAGE} mvn clean package
                    """
                }
            }
            post {
                always {
                    // Collect test reports generated inside Docker
                    junit 'target/surefire-reports/*.xml'

                    // Publish JaCoCo coverage report
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
                    // Run SonarQube analysis with mounted workspace
                    sh """
                        docker run --rm -v $WORKSPACE:/app -w /app ${DOCKER_IMAGE} mvn sonar:sonar
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Rebuild final Docker image if needed
                    sh """
                        docker build -t inventory-service:latest .
                    """
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                script {
                    // Assuming you have a local path with playbooks to mount
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
