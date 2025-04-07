pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Srilatha52/inventory-service.git'
            }
        }
        stage('Build') {
            steps {
                bat 'wsl bash -c "cd /mnt/d/inventory-service-main && ./mvnw clean package"'
            }
        }
        stage('Test') {
            steps {
                bat 'wsl bash -c "cd /mnt/d/inventory-service-main && ./mvnw test"'
            }
            post {
                always {
                    // Windows path for Jenkins to access reports
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
                bat 'wsl bash -c "cd /mnt/d/inventory-service-main && ./mvnw sonar:sonar || echo SonarQube not configured, skipping"'
            }
        }
        stage('Build Docker Image') {
            steps {
                bat 'wsl bash -c "cd /mnt/d/inventory-service-main && docker build -t inventory-service:latest ."'
            }
        }
        stage('Deploy with Ansible') {
            steps {
                bat 'wsl bash -c "cd /mnt/d/inventory-service-main && ansible-playbook -i inventory/localhost.yml deploy.yml"'
            }
        }
        stage('Verify Deployment') {
            steps {
                bat 'timeout 5'
                bat 'wsl bash -c "curl -f http://localhost:8080/api/inventory || exit 1"'
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