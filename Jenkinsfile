pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
  }

  environment {
    TF_IN_AUTOMATION = "true"
    TF_INPUT = "false"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init/Validate') {
      steps {
        dir('terraform') {
          sh 'terraform fmt -check -recursive'
          sh 'terraform init'
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir('terraform') {
          withCredentials([string(credentialsId: 'fgt-token-all', variable: 'FGT_TOKEN')]) {
            sh '''
              terraform plan \
                -var "fgt_token=${FGT_TOKEN}" \
                -out tfplan
            '''
          }
          archiveArtifacts artifacts: 'tfplan', fingerprint: true
        }
      }
    }

    stage('Approval') {
      steps {
        input message: 'Approve applying firewall changes to all 16 devices?'
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          withCredentials([string(credentialsId: 'fgt-token-all', variable: 'FGT_TOKEN')]) {
            sh 'terraform apply -auto-approve tfplan'
          }
        }
      }
    }
  }
}

