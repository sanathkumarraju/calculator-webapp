pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/sanathkumarraju/calculator-webapp.git'
            }
        }

        stage('Verify Repo') {
            steps {
                dir("${env.WORKSPACE}") {
                    sh '''
                    echo "Workspace: $(pwd)"
                    ls -a
                    git remote -v
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            agent {
                docker {
                    image 'docker:25.0'   // Docker CLI image
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                dir("${env.WORKSPACE}") {
                    sh 'docker build -t calculator-app .'
                }
            }
        }

        stage('Deploy') {
            agent {
                docker {
                    image 'docker:25.0'
                    args '-v /var/run/docker.sock:/var/run/docker.sock -p 5000:5000'
                }
            }
            steps {
                sh '''
                docker rm -f calculator || true
                docker run -d --name calculator -p 80:5000 calculator-app
                '''
            }
        }

        stage('Push to DockerHub') {
            agent {
                docker {
                    image 'docker:25.0'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker tag calculator-app:latest $DOCKER_USER/calculator-app:latest
                    docker push $DOCKER_USER/calculator-app:latest
                    '''
                }
            }

            stage('Run Locally') {
                steps {
                    // Stop old container if running
                    sh 'docker rm -f calculator || true'
                    // Pull latest image from Docker Hub
                    sh 'docker pull skraju/calculator-app:latest'
                    // Run new container
                    sh 'docker run -d --name calculator -p 8080:5000 skraju/calculator-app:latest'
                }
            }
        }
    }
}
