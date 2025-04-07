pipeline {
    agent any

    environment {
        PROJECT_DIR = 'D:\\inventory-service-main'
        JAVA_HOME = 'C:\\Program Files\\Java\\jdk-17'  // Update this to your JDK path
        PATH = "${env.JAVA_HOME}\\bin;${env.PATH}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Srilatha52/inventory-service.git'
            }
        }

        stage('Build') {
            steps {
                powershell '''
                    cd $env:PROJECT_DIR
                    ./mvnw clean package
                '''
            }
        }

        stage('Test') {
            steps {
                powershell '''
                    cd $env:PROJECT_DIR
                    ./mvnw test

                    Write-Host "`n Listing contents of target directory:"
                    Get-ChildItem -Recurse "$env:PROJECT_DIR\\target" | ForEach-Object {
                        Write-Host $_.FullName
                    }
                '''
            }
            post {
                always {
                    script {
                        def reportDir = "${env.PROJECT_DIR}\\target\\surefire-reports"
                        def reportGlob = "${reportDir}\\TEST-*.xml"
                        echo "Checking for test reports at: ${reportGlob}"

                        if (fileExists(reportGlob)) {
                            echo "Found test reports. Publishing to JUnit..."
                            junit reportGlob
                        } else {
                            echo "No test report XMLs found in: ${reportDir}"
                        }
                    }

                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: "${env.PROJECT_DIR}\\target\\site\\jacoco",
                        reportFiles: 'index.html',
                        reportName: 'JaCoCo Report'
                    ])
                }
            }
        }

        stage('Code Analysis') {
            steps {
                powershell '''
                    cd $env:PROJECT_DIR
                    try {
                        ./mvnw sonar:sonar
                    } catch {
                        Write-Host 'SonarQube not configured, skipping'
                    }
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                powershell '''
                    cd $env:PROJECT_DIR
                    docker build -t inventory-service:latest .
                '''
            }
        }

        stage('Deploy with Ansible') {
            steps {
                powershell '''
                    cd $env:PROJECT_DIR
                    ansible-playbook -i inventory/localhost.yml deploy.yml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                powershell '''
                    Start-Sleep -Seconds 5
                    try {
                        $response = Invoke-WebRequest -Uri http://localhost:8080/api/inventory -UseBasicParsing
                        if ($response.StatusCode -ne 200) {
                            throw "Unexpected status code: $($response.StatusCode)"
                        }
                        Write-Host "Deployment verified successfully."
                    } catch {
                        Write-Host "Deployment verification failed."
                        exit 1
                    }
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: "${env.PROJECT_DIR}\\target\\*.jar", allowEmptyArchive: true
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed.'
        }
    }
}