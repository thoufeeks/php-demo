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
            }
        }

 

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarQube Scanner'

 

                    withSonarQubeEnv('sonar') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
    }

 

    post {
        always {
            // Cleanupg or other post-build actions
        }
    }
}
