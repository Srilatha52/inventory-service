pipeline {
    agent any
    environment {
        // Optional: Set JAVA_HOME if needed in Windows
        JAVA_HOME = "C:\\path\\to\\jdk-22"  // Adjust if JDK is installed in Windows
    }
    stages {
        stage('Checkout') {
            steps {
                // Pulls from Git
                git branch: 'main', url: 'https://github.com/Srilatha52/inventory-service.git'
            }
        }
        stage('Build') {
            steps {
                bat 'mvnw.cmd clean package'
            }
        }
        stage('Test') {
            steps {
                bat 'mvnw.cmd test'
            }
            post {
                always {
                    // Publish test results and JaCoCo report
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
                // Skip if SonarQube not configured
                bat 'mvnw.cmd sonar:sonar || echo "SonarQube not configured, skipping"'
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
                bat 'timeout 5'  // Wait for container to start
                bat 'curl -f http://localhost:8080/api/inventory || exit /b 1'
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