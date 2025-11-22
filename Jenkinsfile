pipeline{
    agent any
    environment {
        RFEGISTRY = "docker.io/apelsin16/lab8"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }
    stages {
        stage("Checkout") {
            steps{
                checkout scm
            }
        }
    }
}