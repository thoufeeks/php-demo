curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH




pipeline {
    agent any

    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }

    environment {
        SCANNER_HOME = tool 'sonarqube-scanner'
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/thoufeeks/a-swig.git'
            }
        }

        stage("Sonarqube Analysis") {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=Swiggy-CI \
                        -Dsonar.projectKey=Swiggy-CI'''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }

        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }

        stage("Docker Build & Push") {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'dockerhub', toolName: 'docker') {
                        sh "docker build -t swiggy-clone ."
                        sh "docker tag swiggy-clone thoufeek/swiggy-clone:latest"
                        sh "docker push thoufeek/swiggy-clone:latest"
                    }
                }
            }
        }

        stage("TRIVY Image Scan") {
            steps {
                sh "trivy image thoufeek/swiggy-clone:latest > trivyimage.txt"
            }
        }

        stage("Dev Deployment - Docker Run") {
            steps {
                script {
                    sh "docker rm -f swiggy-container || true"
                    sh "docker run -d -p 3000:3000 --name swiggy-container thoufeek/swiggy-clone:latest"
                }
            }
        }

        stage('Approval Before Prod Deployment') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    input message: 'Approve Production Deployment?', ok: 'Deploy to Prod'
                }
            }
        }

        stage("Prod Deployment - Kubernetes") {
            steps {
                script {
                    withKubeConfig(credentialsId: 'kubeconfig-prod') {
                        sh 'kubectl apply -f k8s/'
                        sh 'kubectl rollout status deployment swiggy-deployment -n production'
                    }
                }
            }
        }
    }
}
