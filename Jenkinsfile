pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo/node-eks-app.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarQube') {  // Name from Jenkins Global Config
                    sh '''
                       sonar-scanner \
                       -Dsonar.projectKey=node-eks-app \
                       -Dsonar.sources=. \
                       -Dsonar.host.url=$SONAR_HOST_URL \
                       -Dsonar.login=$SONAR_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t your-dockerhub-username/node-eks-app:${BUILD_NUMBER} .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh 'echo $PASS | docker login -u $USER --password-stdin'
                    sh 'docker push your-dockerhub-username/node-eks-app:${BUILD_NUMBER}'
                    sh 'docker tag your-dockerhub-username/node-eks-app:${BUILD_NUMBER} your-dockerhub-username/node-eks-app:latest'
                    sh 'docker push your-dockerhub-username/node-eks-app:latest'
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh 'kubectl set image deployment/node-eks-app node-eks-app=your-dockerhub-username/node-eks-app:${BUILD_NUMBER} --record || kubectl apply -f k8s/'
            }
        }
    }
}
