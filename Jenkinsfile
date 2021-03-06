String es_dir = "elasticsearch"
String ls_dir = "logstash"
String kb_dir = "kibana"
String fb_dir = "filebeat"

String es_regex = "**/${es_dir}/**"
String ls_regex = "**/${ls_dir}/**"
String kb_regex = "**/${kb_dir}/**"
String fb_regex = "**/${fb_dir}/**"

def remote = [:]
remote.name = 'labsrv'
remote.host = '100.0.0.1'
remote.user = 'ladmin'
remote.password = 'P@ssw0rd' /* yes this should be handled via certificates */
remote.allowAnyHosts = true   

parameters { choice(name: 'DEPLOY', choices: ['everything', 'changes'], description: 'What do you want to deploy today?') }

pipeline {

    agent any

    stages {

        // not required if done from the configuration of the job
        /*stage("Checkout code") {
            steps {
                git url: 'http://100.0.0.2:3000/zeus/pipeline.git'
            }
        }*/
        
        stage("Sanity check") {
            steps {
                echo "This job will build: $DEPLOY"
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/tests/sanity-test.yaml"
            }
            post{
                failure {
                    script{
                        error "Sanity check failed, exiting now..."
                    }
                }
            }
        }
        
        /* --------------------------- Elasticsearch ---------------------------*/

        stage("BUILD Elasticsearch") {
           when { 
                anyOf {
                    changeset es_regex
                    expression { params.DEPLOY == 'everything' }
                }
            }
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/elasticsearch/deploy.yaml"
            }
            post{
                failure {
                    script{
                        error "Elasticsearch deployment failed, exiting now..."
                    }
                }
            }
        }
        
        stage("TEST Elasticsearch") {
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/elasticsearch/test.yaml"
            }
            post{
                failure {
                    script{
                        error "Elasticsearch test failed, exiting now..."
                    }
                }
            }
        }

        /* --------------------------- Logstash ---------------------------*/
    
        stage("BUILD Logstash") {
           when { 
                anyOf {
                    changeset ls_regex
                    expression { params.DEPLOY == 'everything' }
                }
            }
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/logstash/deploy.yaml"
            }
            /* since it's not really used by anything atm, this could fail but the job can continue 
            consider adding a try/catch block. Same for testing
            */
        }
        
        stage("TEST Logstash") {
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/logstash/test.yaml"
            }
        }

        /* --------------------------- Kibana ---------------------------*/

        stage("BUILD Kibana") {
           when { 
                anyOf {
                    changeset kb_regex
                    expression { params.DEPLOY == 'everything' }
                }
            }
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/kibana/deploy.yaml"
            }
            post{
                failure {
                    script{
                        error "Kibana deployment failed, exiting now..."
                    }
                }
            }
        }
        
        stage("TEST Kibana") {
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/kibana/test.yaml"
            }
            post{
                failure {
                    script{
                        error "Kibana test failed, exiting now..."
                    }
                }
            }
        }

        /* --------------------------- Filebeat ---------------------------*/

        stage("BUILD Filebeat") {
           when { 
                anyOf {
                    changeset fb_regex
                    expression { params.DEPLOY == 'everything' }
                }
            }
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/filebeat/deploy.yaml"
            }
            post{
                failure {
                    script{
                        error "Filebeat deployment failed, exiting now..."
                    }
                }
            }
        }
        
        stage("TEST Filebeat") {
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/filebeat/test.yaml"
            }
            post{
                failure {
                    script{
                        error "Filebeat test failed, exiting now..."
                    }
                }
            }
        }

        /* --------------------------- Mo testing ---------------------------*/

        stage("TEST Security") {
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/tests/security-test.yaml"
            }
        }

        stage("TEST Performance") {
            steps {
                sshCommand remote: remote, command: "ansible-playbook -i /mnt/challenge/hosts /mnt/challenge/app/prod/tests/perf-test.yaml"
            }
        }

        /* --------------------------- Landing ---------------------------*/

        stage("Cleanup and Report") {
            steps {
                echo "Sending report with email and deleting build artefacts"
            }
        }

    }
}