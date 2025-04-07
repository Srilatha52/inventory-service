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

        stage('Build & Test in Docker') {
            steps {
                script {
                    def windowsPath = "${env.WORKSPACE}".replace('\\', '/')
                    def unixPath = windowsPath.replaceFirst(/^([A-Za-z]):/, '/$1').toLowerCase()

                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE} ."

                    // Run Maven inside container by cd'ing to folder instead of using -w
                    sh """
                        docker run --rm \
                        -v ${unixPath}:${unixPath} \
                        ${DOCKER_IMAGE} sh -c "cd ${unixPath} && mvn clean verify"
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
                        reportName: 'JaCoCo Report'
                    ])
                }
            }
        }

        stage('Code Analysis with SonarQube') {
            steps {
                script {
                    def windowsPath = "${env.WORKSPACE}".replace('\\', '/')
                    def unixPath = windowsPath.replaceFirst(/^([A-Za-z]):/, '/$1').toLowerCase()

                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                            docker run --rm \
                            -e SONAR_TOKEN=${SONAR_TOKEN} \
                            -e SONAR_HOST_URL=http://host.docker.internal:9000 \
                            -v ${unixPath}:${unixPath} \
                            ${DOCKER_IMAGE} sh -c "cd ${unixPath} && mvn sonar:sonar"
                        """
                    }
                }
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
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}
