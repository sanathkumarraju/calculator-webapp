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
            steps {
                dir("${env.WORKSPACE}") {
                    sh 'docker build -t calculator-app .'
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker rm -f calculator || true
                docker run -d --name calculator -p 80:5000 calculator-app
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker tag calculator-app:latest $DOCKER_USER/calculator-app:latest
                    docker push $DOCKER_USER/calculator-app:latest
                    '''
                }
            }
        }
    }
}