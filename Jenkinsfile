pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                // Build your HTML code here if needed
                sh 'echo "Building HTML code"'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube Scanner'

                    withSonarQubeEnv('sonar') {
                        sh "java -jar ${scannerHome}/lib/sonar-scanner-cli-4.6.2.2472.jar"  // Update the jar filename with the correct version
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed"
        }
    }
}
