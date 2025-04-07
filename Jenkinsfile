pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                bat './mvnw clean package'
            }
        }
        stage('Test') {
            steps {
                bat './mvnw test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    publishHTML(target: [reportDir: 'target/site/jacoco', reportFiles: 'index.html', reportName: 'JaCoCo Report'])
                }
            }
        }
        stage('Code Analysis') {
            steps {
                bat 'mvnw.cmd sonar:sonar'
            }
        }
        stage('Build Docker Image') {
            steps {
                bat 'docker build -t inventory-service:latest .'
            }
        }
        stage('Deploy with Ansible') {
            steps {
                bat 'wsl ansible-playbook -i inventory/localhost.yml deploy.yml'
            }
        }
        stage('Verify Deployment') {
            steps {
                bat 'timeout 5'
                bat 'curl -f http://localhost:8080/api/inventory || exit /b 1'  # Use 8082 if changed
            }
        }
    }
    post {
        always {
            archiveArtifacts 'target/*.jar'
        }
    }
}