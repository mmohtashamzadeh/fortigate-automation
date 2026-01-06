pipeline {
  agent any

  options {
    timestamps()
    ansiColor('xterm')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timeout(time: 30, unit: 'MINUTES')
  }

  parameters {
    booleanParam(name: 'RUN_ANSIBLE_BACKUP', defaultValue: true, description: 'Take pre-change backups (Ansible) and archive them as Jenkins artifacts')
    booleanParam(name: 'RUN_ANSIBLE_OPS', defaultValue: true, description: 'Run post-apply operational verification (Ansible)')
  }

  environment {
    TF_IN_AUTOMATION = "true"
    TF_INPUT         = "false"
    TF_CLI_ARGS_plan  = "-no-color"
    TF_CLI_ARGS_apply = "-no-color"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
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

    stage('Prepare Artifacts Dir') {
      when { expression { return params.RUN_ANSIBLE_BACKUP } }
      steps {
        sh 'mkdir -p artifacts/backups'
      }
    }

    stage('Pre-Change Backup (Ansible)') {
      when { expression { return params.RUN_ANSIBLE_BACKUP } }
      steps {
        dir('ansible') {
          withCredentials([string(credentialsId: 'fgt-token-all', variable: 'FGT_TOKEN')]) {
            sh '''
              ansible-playbook -i inventory/dev.ini playbooks/backup.yml \
                --extra-vars "fgt_token=${FGT_TOKEN}"
            '''
          }
        }
      }
    }

    stage('Archive Backups') {
      when { expression { return params.RUN_ANSIBLE_BACKUP } }
      steps {
        archiveArtifacts artifacts: 'artifacts/backups/**', fingerprint: true, allowEmptyArchive: true
      }
    }

    stage('Approval') {
      steps {
        input message: 'Approve applying firewall changes to ALL 16 FortiGates?'
      }
    }

    stage('Terraform Apply') {
      steps {
        dir('terraform') {
          sh 'terraform apply -auto-approve tfplan'
        }
      }
    }

    stage('Post-Apply Ops (Ansible)') {
      when { expression { return params.RUN_ANSIBLE_OPS } }
      steps {
        dir('ansible') {
          withCredentials([string(credentialsId: 'fgt-token-all', variable: 'FGT_TOKEN')]) {
            sh '''
              ansible-playbook -i inventory/dev.ini playbooks/ops_apply.yml \
                --extra-vars "fgt_token=${FGT_TOKEN}"
            '''
          }
        }
      }
    }
  }

  post {
    always {
      // Keep useful logs visible even if a stage fails
      dir('terraform') {
        sh 'terraform version || true'
      }
      // Don't wipe artifacts/backups before Jenkins archives them (already archived in stage)
      cleanWs(deleteDirs: true, disableDeferredWipeout: true, notFailBuild: true)
    }
  }
}
