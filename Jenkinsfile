pipeline {
    agent any
    environment{
        DOCKER_TAG="${getShortCommitHash()}"
    }
    stages {
        stage("Code Checkout"){
            steps{
                git branch: 'main', url: 'https://github.com/javahometech/java-app-jenkins'
            }
        }
        stage('SonarQube Scanner') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh "mvn sonar:sonar"
                }
            }
        }
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage("Docker Build"){
            steps{
                sh "docker build -t kammana/java-app-jenkins:${env.DOCKER_TAG} ."
            }
        }
        stage("Trivy Scan"){
            steps{
               
                sh "export TMPDIR=${WORKSPACE} && trivy image --severity HIGH,CRITICAL --exit-code 0 kammana/java-app-jenkins:${env.DOCKER_TAG}"
            }
        }
        stage("Docker Push"){
            steps{
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'pwd', usernameVariable: 'user')]) {
                    sh "docker login -u ${user} -p ${pwd}"
                    sh "docker push kammana/java-app-jenkins:${env.DOCKER_TAG}"
                }
            }
        }
        stage("Update k8s Manifest files") {
            steps {
                sh 'yq -i ".spec.template.spec.containers[0].image = \\"kammana/java-app-jenkins:\\" + strenv(DOCKER_TAG)" ./k8s/java-app-deployment.yml'
            }
        }
        stage('Push K8s Changes') {
            steps {
                withCredentials([gitUsernamePassword(credentialsId: 'github-creds', gitToolName: 'Default')]) {
                    sh '''
                        git config user.email "jenkins@javahome.in"
                        git config user.name "Jenkins Build"
                        git add .
                        git diff --cached --quiet || git commit -m "Jenkins updated k8s manifest file"
                        git push origin main
                    '''
                }
            }
        }
    }
}
def getShortCommitHash(){
    return sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
}
