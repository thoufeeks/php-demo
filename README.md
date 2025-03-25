pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    stages {
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout SCM') {
            steps {
                git 'https://github.com/priyanshu-bhatt/DevSecOps-CI-CD-Pipeline.git'
            }
        }
        stage('Compiling Maven Code') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Maven Test') {
            
            }
            steps {
                sh 'mvn test'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Petshop \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=Petshop '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonarqube-token'
                }
            }
        }
        stage('Building WAR File Using Maven') {
            steps {
                sh 'mvn clean install -DskipTests=true'
            }
        }
        stage('OWASP Dependency Checking') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format XML', odcInstallation: 'dependency-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Building and Pushing to Docker Hub') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t thoufeek/petshop:${BUILD_TAG} ."
                        sh "docker push thoufeek/petshop:${BUILD_TAG}"
                    }
                }
            }
        }
        stage('Image Scanning Using Trivy') {
            steps {
                sh "trivy image thoufeek/petshop:${BUILD_TAG} > trivy.txt"
            }
        }
        stage('Deploy to DEV') {
            steps {
                sh 'docker rm -f devcontainer'
                sh 'docker run -d --name devcontainer -p 80:8080 thoufeek/petshop:latest'
            }
        }
    }
}
