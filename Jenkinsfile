pipeline {
    agent {
        label 'local-agent'  // Ensure the Jenkins agent has Minikube and kubectl installed
    }

    environment {
        IMAGE_NAME = 'fitness-web-app'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Push') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'docker-hub',
                            usernameVariable: 'USERNAME',
                            passwordVariable: 'PASSWORD'
                        )
                    ]) {
                        echo 'Logging into Docker Hub...'
                        sh 'docker login --username $USERNAME --password $PASSWORD'

                        echo 'Tagging Docker image...'
                        sh "docker tag ${IMAGE_NAME} $USERNAME/${IMAGE_NAME}"

                        echo 'Pushing Docker image...'
                        sh "docker push $USERNAME/${IMAGE_NAME}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo 'Checking Minikube status...'
                    
                    // Check if the Minikube profile exists
                    def profileExists = sh(script: 'minikube profile list', returnStdout: true).trim()
                    
                    if (!profileExists.contains('minikube')) {
                        echo 'No Minikube profile found. Starting Minikube...'
                        sh 'minikube start'
                    } else {
                        echo 'Minikube profile found.'
                    }

                    echo 'Setting kubectl context to Minikube...'
                    sh 'kubectl config use-context minikube'

                    echo 'Deploying to Kubernetes...'
                    sh 'kubectl apply -f ./k8s/deployment.yaml'
                }
            }
        }
    }
}
