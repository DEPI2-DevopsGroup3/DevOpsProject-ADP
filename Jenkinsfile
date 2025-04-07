pipeline {
    agent any 

    environment {
    IMAGE_NAME = "fitness-web-app"
    CONTAINER_NAME = "fitness-web-app"
    HOST_PORT = 8000
    CONTAINER_PORT = 8000
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

        stage('Deploy') {
            steps {
                script {
            withCredentials([
                usernamePassword(
                    credentialsId: 'docker-hub',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )
            ]) {
                def fullImageName = "${USERNAME}/fitness-web-app:latest"

                echo 'Pulling Docker image...'
                sh "docker pull ${fullImageName}"

                echo 'Running Docker container...'
                sh """
                    docker run -d \
                      --name ${CONTAINER_NAME} \
                      -p ${HOST_PORT}:${CONTAINER_PORT} \
                      ${fullImageName}
                """
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Pull the latest image
                    sh "docker pull ${IMAGE_NAME}"

                    // Run the container
                    sh """
                        docker run -d \
                          --name ${CONTAINER_NAME} \
                          -p ${HOST_PORT}:${CONTAINER_PORT} \
                          ${IMAGE_NAME}
                    """
                }
            }
        }

        stage('Verify') {
            steps {
                script {
                    // Check if container is running
                    sh "docker ps --filter name=${CONTAINER_NAME}"

                    // Optional: Test HTTP endpoint (adjust URL if needed)
                    sh "curl -s http://localhost:${HOST_PORT} || true"
                }
            }
        }
    }
}
