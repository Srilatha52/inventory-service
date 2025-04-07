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
                    sh "docker build -t ${DOCKER_IMAGE} ."

                    // Convert Windows path to Docker-compatible Unix-style path
                    def unixWorkspace = WORKSPACE.replaceAll('\\\\', '/').replaceAll('C:', '/c')

                    // Run tests and generate reports
                    sh """
                        docker run --rm -v ${unixWorkspace}:/app -w /app ${DOCKER_IMAGE} mvn clean package
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
                    def unixWorkspace = WORKSPACE.replaceAll('\\\\', '/').replaceAll('C:', '/c')

                    sh """
                        docker run --rm -v ${unixWorkspace}:/app -w /app ${DOCKER_IMAGE} mvn sonar:sonar
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t inventory-service:latest ."
                }
            }
        }

        stage('Deploy with Ansible') {
            steps {
                script {
                    def unixWorkspace = WORKSPACE.replaceAll('\\\\', '/').replaceAll('C:', '/c')
                    def ansiblePlaybookPath = '/c/Users/srila/ansible' // Update this to your actual path

                    sh """
                        docker run --rm \
                            -v ${ansiblePlaybookPath}:/ansible \
                            -v ${unixWorkspace}:/app \
                            -w /ansible \
                            ${DOCKER_IMAGE} \
                            ansible-playbook -i inventory/localhost.yml deploy.yml
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
