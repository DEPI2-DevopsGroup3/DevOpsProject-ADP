pipeline {
    agent {
      label 'aws-agent'
    }
    triggers {
        githubPush()  // listens for push events from GitHub webhook
	}
    environment {
       IMAGE_NAME = 'fitness-web-app'
       CONTAINER_NAME = 'fitness-web-app'
       HOST_PORT = 80
       CONTAINER_PORT = 80
    }

    stages {
        stage('Build') {
            steps {
                script {
                    echo 'Building Docker image........'
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
            withCredentials([
                usernamePassword(
                    credentialsId: 'docker-hub',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )
            ]) {
                def fullImageName = "${USERNAME}/${IMAGE_NAME}"

                echo 'Pulling Docker image...'
                sh "docker pull ${fullImageName}"

                echo 'Removing any existing container...'
                sh "docker rm -f ${CONTAINER_NAME} || true"
                
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

post {
  success {
    slackSend(
      channel: '#project-channel',
      color: '#36a64f', // Green
      message: """
:white_check_mark: *Build SUCCESS* - `${env.JOB_NAME} #${env.BUILD_NUMBER}`
<${env.BUILD_URL}|View the Jenkins build>

*Monitoring Tools:*
• <http://13.60.41.46:9090|Prometheus>
• <http://13.60.41.46:3000|Grafana>
• <http://13.60.41.46:8080|cAdvisor>
"""
.trim(),
      teamDomain: 'DEPI2-DevopsGroup3',
      tokenCredentialId: 'slack-token'
    )
  }
  failure {
    slackSend(
      channel: '#project-channel',
      color: '#FF0000', // Red
      message: ":x: *Build FAILURE* - `${env.JOB_NAME} #${env.BUILD_NUMBER}`\n<${env.BUILD_URL}|Click here to view the build>",
      teamDomain: 'DEPI2-DevopsGroup3',
      tokenCredentialId: 'slack-token'
    )
  }
}



}
