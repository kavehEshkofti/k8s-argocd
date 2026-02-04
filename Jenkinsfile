pipeline{
    agent any
    stages{
        stage("Code Checkout"){
            steps{
                git branch: 'main', credentialsId: 'github-creds', url: 'https://github.com/javahometech/java-app-jenkins'
            }
        }
        stage("Maven Build"){
            steps{
                sh 'mvn clean package'
            }
        }
        stage("Deploy to Tomcat"){
            steps{
                sshagent(['tomcat-dev']) {
                    sh "scp -o StrictHostKeyChecking=no target/*.war ec2-user@172.31.17.118:/opt/tomcat9/webapps/"
                    sh "ssh ec2-user@172.31.17.118 /opt/tomcat9/bin/shutdown.sh"
                    sh "ssh ec2-user@172.31.17.118 /opt/tomcat9/bin/startup.sh"
                }
            }
        }
    }
}
