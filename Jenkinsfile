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
                            mvn clean package
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
                SONAR_TOKEN = credentials('SONAR_TOKEN') // Securely inject token from Jenkins
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
                            mvn sonar:sonar -Dsonar.token=${SONAR_TOKEN}
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
                    def unixWorkspace = WORKSPACE.replace('\\', '/').replace('C:', '/c')
                    def ansiblePath = '/c/Users/srila/ansible' // Update if needed

                    bat """
                        docker run --rm ^
                            -v "${ansiblePath}:/ansible" ^
                            -v "${unixWorkspace}:${unixWorkspace}" ^
                            -w /ansible ^
                            ${DOCKER_IMAGE} ^
                            ansible-playbook -i inventory/localhost.yml deploy.yml
                    """
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