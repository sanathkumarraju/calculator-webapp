pipeline {
    agent any
    environment {
        VM_HOST = 'root@192.168.29.201'
        IMAGE_NAME = 'skraju/calculator-app:latest'
        CONTAINER_NAME = 'calculator'
    }   

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
        }

        stage('Run Locally') {
            steps {
                // Stop old container if running
                sh 'docker rm -f calculator || true'
                // Pull latest image from Docker Hub
                sh 'docker pull skraju/calculator-app:latest'
                //Run new container
                sh 'docker run -d --name calculator -p 80:5000 skraju/calculator-app:latest'
            }
        }

        stage('Deploy_vm') {
            steps {
                sh '''
                scp -r * root@192.168.29.201:/opt/calculator-app
                ssh root@192.168.29.201 "pkill -f app.py || true && nohup python3 /opt/calculator-app/app.py &"
                '''
            }
        }

        stage('Run Locally_VM') {
            steps {
                sh '''
                    ssh ${VM_HOST} "
                        // Stop old container if running
                        docker rm -f calculator || true
                        // Pull latest image from Docker Hub
                        docker pull skraju/calculator-app:latest
                        //Run new container
                        docker run -d --name calculator -p 80:5000 skraju/calculator-app:latest
                    "
                '''
            }
        }
        stage('Health Check') {
            steps {
                sh """
                    ssh ${VM_HOST} '
                        # Wait a few seconds for container startup
                        sleep 5
                        # Test if the app responds on port 80
                        curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep 200
                    '
                
                """
            }
        }
    }
}
