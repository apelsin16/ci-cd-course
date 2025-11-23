pipeline {
    agent any

    environment {
        ECR_REPO = "803238624325.dkr.ecr.us-west-2.amazonaws.com/lesson-8-ecr"
        IMAGE_TAG = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }

    stages {
        stage('Build & Push with Kaniko') {
            agent {
                kubernetes {
                    yaml '''
                    apiVersion: v1
                    kind: Pod
                    spec:
                      containers:
                      - name: kaniko
                        image: gcr.io/kaniko-project/executor:latest
                        args: ["--cache=true","--cache-ttl=48h"]
                        volumeMounts:
                        - name: docker-config
                          mountPath: /kaniko/.docker
                      volumes:
                      - name: docker-config
                        configMap:
                          name: docker-config
                    '''
                }
            }
            steps {
                container('kaniko') {
                    sh """
                    /kaniko/executor \
                      --dockerfile=Dockerfile \
                      --context=dir://${WORKSPACE} \
                      --destination=${ECR_REPO}:${IMAGE_TAG} \
                      --destination=${ECR_REPO}:latest
                    """
                }
            }
        }

        stage('Update Helm chart') {
            agent {
                kubernetes {
                    yaml '''
                    apiVersion: v1
                    kind: Pod
                    spec:
                      containers:
                      - name: git
                        image: alpine/git
                        command: ["/bin/sh","-c","cat"]
                        tty: true
                        volumeMounts:
                        - name: ssh-key
                          mountPath: /root/.ssh
                      volumes:
                      - name: ssh-key
                        secret:
                          secretName: github-ssh-key
                          items:
                          - key: ssh-privatekey
                            path: id_ed25519
                            mode: 0400
                    '''
                }
            }
            steps {
                container('git') {
                    sh '''
                    mkdir -p ~/.ssh && cp /root/.ssh/id_ed25519 ~/.ssh/
                    ssh-keyscan github.com >> ~/.ssh/known_hosts
                    git config --global user.email "jenkins@ci.com"
                    git config --global user.name "Jenkins"
                    sed -i "s|tag:.*|tag: ${IMAGE_TAG}|" charts/django-app/values.yaml
                    git add charts/django-app/values.yaml
                    git commit -m "ci: update tag to ${IMAGE_TAG}"
                    git push origin HEAD:lesson-8-9
                    '''
                }
            }
        }
    }
}