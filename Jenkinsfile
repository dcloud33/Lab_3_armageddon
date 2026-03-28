pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    parameters {
        choice(name: 'STACK', choices: ['Tokyo', 'Sao_Paulo', 'Global'], description: 'Which Terraform stack to run')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
        booleanParam(name: 'ENABLE_SAOPAULO_ACCEPT', defaultValue: false, description: 'Used only for Tokyo stack')
        booleanParam(name: 'CONFIRM_DESTROY', defaultValue: false, description: 'Must be true to allow destroy')
        booleanParam(name: 'ENABLE_TOKYO_ROUTE', defaultValue: true, description: 'Enable TGW route from Sao Paulo to Tokyo'
)
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION   = 'true'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Verify Tools') {
            steps {
                sh '''
                  whoami
                  pwd
                  terraform version
                  aws --version
                  aws sts get-caller-identity
                '''
            }
        }

        stage('Pre-Check Safety Rules') {
            steps {
                script {
                    if (params.ACTION == 'destroy' && !params.CONFIRM_DESTROY) {
                        error("Destroy blocked: set CONFIRM_DESTROY=true before running destroy.")
                    }

                    if (params.ACTION == 'destroy') {
                        echo 'Recommended destroy order: Global -> Sao_Paulo -> Tokyo'
                    }
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    if (params.STACK == 'Tokyo') {
                        sh 'terraform -chdir=Tokyo init -input=false'
                    }

                    if (params.STACK == 'Sao_Paulo') {
                        sh 'terraform -chdir=Sao_Paulo init -input=false'
                    }

                    if (params.STACK == 'Global') {
                        sh 'terraform -chdir=Global init -input=false'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            when {
                expression { params.ACTION != 'destroy' }
            }
            steps {
                script {
                    if (params.STACK == 'Tokyo') {
                        sh 'terraform -chdir=Tokyo validate'
                    }

                    if (params.STACK == 'Sao_Paulo') {
                        sh 'terraform -chdir=Sao_Paulo validate'
                    }

                    if (params.STACK == 'Global') {
                        sh 'terraform -chdir=Global validate'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    if (params.STACK == 'Tokyo') {
                        if (params.ACTION == 'destroy') {
                            sh """
                              terraform -chdir=Tokyo plan \
                                -destroy \
                                -input=false \
                                -var="enable_saopaulo_accept=${params.ENABLE_SAOPAULO_ACCEPT}" \
                                -out=tfplan
                            """
                        } else {
                            sh """
                              terraform -chdir=Tokyo plan \
                                -input=false \
                                -var="enable_saopaulo_accept=${params.ENABLE_SAOPAULO_ACCEPT}" \
                                -out=tfplan
                            """
                        }
                    }

                    if (params.STACK == 'Sao_Paulo') {
                        if (params.ACTION == 'destroy') {
                            sh """
                              terraform -chdir=Sao_Paulo plan \
                                -destroy \
                                -input=false \
                                -var="enable_tokyo_route=${params.ENABLE_TOKYO_ROUTE}" \
                                -out=tfplan
                            """
                        } else {
                            sh """
                              terraform -chdir=Sao_Paulo plan \
                                -input=false \
                                -var="enable_tokyo_route=${params.ENABLE_TOKYO_ROUTE}" \
                                -out=tfplan
                            """
                        }
                    }

                    if (params.STACK == 'Global') {
                        if (params.ACTION == 'destroy') {
                            sh '''
                              terraform -chdir=Global plan \
                                -destroy \
                                -input=false \
                                -out=tfplan
                            '''
                        } else {
                            sh '''
                              terraform -chdir=Global plan \
                                -input=false \
                                -out=tfplan
                            '''
                        }
                    }
                }
            }
        }

        stage('Manual Approval') {
            when {
                expression { params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                input message: "Proceed with ${params.ACTION} for ${params.STACK}?", ok: 'Continue'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    if (params.STACK == 'Tokyo') {
                        sh 'terraform -chdir=Tokyo apply -input=false -auto-approve tfplan'
                    }

                    if (params.STACK == 'Sao_Paulo') {
                        sh 'terraform -chdir=Sao_Paulo apply -input=false -auto-approve tfplan'
                    }

                    if (params.STACK == 'Global') {
                        sh 'terraform -chdir=Global apply -input=false -auto-approve tfplan'
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    if (params.STACK == 'Tokyo') {
                        echo 'Destroying Tokyo last is recommended.'
                        sh 'terraform -chdir=Tokyo apply -input=false -auto-approve tfplan'
                    }

                    if (params.STACK == 'Sao_Paulo') {
                        echo 'Destroying Sao_Paulo after Global is recommended.'
                        sh 'terraform -chdir=Sao_Paulo apply -input=false -auto-approve tfplan'
                    }

                    if (params.STACK == 'Global') {
                        echo 'Destroying Global first is recommended.'
                        sh 'terraform -chdir=Global apply -input=false -auto-approve tfplan'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo "SUCCESS: ${params.STACK} ${params.ACTION}"
        }
        failure {
            echo 'FAILED: Check Jenkins console output carefully.'
        }
    }
}