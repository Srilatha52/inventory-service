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
                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE} ."

                    // Convert Windows path to Unix path for volume mount
                    def unixWorkspace = WORKSPACE.replaceAll('\\\\', '/').replaceAll('C:', '/c')

                    // Run tests and generate coverage
                    sh """
                        docker run --rm -v ${unixWorkspace}:${unixWorkspace} -w ${unixWorkspace} ${DOCKER_IMAGE} mvn clean verify
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
                    sh """
                        docker run --rm -e SONAR_HOST_URL=http://host.docker.internal:9000 -e SONAR_TOKEN=<squ_4985d7be0d87edee0f5aa2c58770441f372eddbf> \
                        -v ${env.WORKSPACE}:${env.WORKSPACE} -w ${env.WORKSPACE} ${DOCKER_IMAGE} mvn sonar:sonar
                    """
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t inventory-service:latest ."
            }
        }

        stage('Deploy with Ansible') {
            steps {
                // Runs Ansible inside real WSL Ubuntu with project copied to ~/inventory-service-main
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
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
