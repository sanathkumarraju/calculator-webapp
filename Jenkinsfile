pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/yourusername/calculator-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t calculator-app .'
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
    }
}