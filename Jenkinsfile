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
    choice(name: 'ENV', choices: ['dev', 'prod'], description: 'Target environment')
    booleanParam(name: 'RUN_ANSIBLE_BACKUP', defaultValue: true, description: 'Backup before applying changes')
    booleanParam(name: 'RUN_ANSIBLE_OPS', defaultValue: true, description: 'Run operational playbook after apply')
    booleanParam(name: 'AUTO_APPLY_DEV', defaultValue: true, description: 'Auto-apply in dev on main branch')
  }

  environment {
    TF_IN_AUTOMATION = "true"
    TF_INPUT = "false"
    TF_CLI_ARGS_plan = "-no-color"
    TF_CLI_ARGS_apply = "-no-color"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Set Environment') {
      steps {
        script {
          env.TFVARS = "envs/${params.ENV}.tfvars"
          env.TF_DIR = "terraform"
          env.ANSIBLE_DIR = "ansible"

          // Recommended: store credentials in Jenkins Credentials
          // Create Jenkins credentials:
          // - Secret text: fgt-token-dev / fgt-token-prod
          // - String: fgt-host-dev / fgt-host-prod (or plain env)
          if (params.ENV == 'dev') {
            env.FGT_HOST_CRED = 'fgt-host-dev'
            env.FGT_TOKEN_CRED = 'fgt-token-dev'
            env.ANSIBLE_INV = "inventory/dev.ini"
          } else {
            env.FGT_HOST_CRED = 'fgt-host-prod'
            env.FGT_TOKEN_CRED = 'fgt-token-prod'
            env.ANSIBLE_INV = "inventory/prod.ini"
          }
        }
      }
    }

    stage('Terraform Format & Validate') {
      steps {
        dir("${env.TF_DIR}") {
          sh 'terraform fmt -check -recursive'
          sh 'terraform init -upgrade'
          sh 'terraform validate'
        }
      }
    }

    stage('Terraform Plan') {
      steps {
        dir("${env.TF_DIR}") {
          withCredentials([
            string(credentialsId: "${env.FGT_HOST_CRED}", variable: 'FGT_HOST'),
            string(credentialsId: "${env.FGT_TOKEN_CRED}", variable: 'FGT_TOKEN')
          ]) {
            sh """
              terraform plan \
                -var 'fgt_host=${FGT_HOST}' \
                -var 'fgt_token=${FGT_TOKEN}' \
                -var-file '../${TFVARS}' \
                -out tfplan
            """
          }
          archiveArtifacts artifacts: 'tfplan', fingerprint: true
        }
      }
    }

    stage('Pre-Change Backup (Ansible)') {
      when { expression { return params.RUN_ANSIBLE_BACKUP } }
      steps {
        dir("${env.ANSIBLE_DIR}") {
          withCredentials([string(credentialsId: "${env.FGT_TOKEN_CRED}", variable: 'FGT_TOKEN')]) {
            sh """
              ansible-playbook -i ${ANSIBLE_INV} playbooks/backup.yml \
                --extra-vars "fgt_token=${FGT_TOKEN}"
            """
          }
        }
      }
    }

    stage('Approval Gate') {
      when {
        anyOf {
          expression { return params.ENV == 'prod' }
          expression { return env.BRANCH_NAME == 'main' && params.ENV == 'prod' }
        }
      }
      steps {
        input message: "Approve applying firewall changes to ${params.ENV}?"
      }
    }

    stage('Apply') {
      steps {
        script {
          // Lock per environment to avoid two applies hitting same device(s)
          lock(resource: "fortigate-${params.ENV}") {
            dir("${env.TF_DIR}") {
              withCredentials([
                string(credentialsId: "${env.FGT_HOST_CRED}", variable: 'FGT_HOST'),
                string(credentialsId: "${env.FGT_TOKEN_CRED}", variable: 'FGT_TOKEN')
              ]) {

                // Safe default: only apply automatically on main in dev (if enabled)
                def isMain = (env.BRANCH_NAME == 'main')
                def autoApplyAllowed = (params.ENV == 'dev' && params.AUTO_APPLY_DEV && isMain)

                if (!autoApplyAllowed) {
                  input message: "Apply changes now? (env=${params.ENV}, branch=${env.BRANCH_NAME})"
                }

                sh """
                  terraform apply -auto-approve tfplan
                """
              }
            }
          }
        }
      }
    }

    stage('Post-Apply Ops (Ansible)') {
      when { expression { return params.RUN_ANSIBLE_OPS } }
      steps {
        dir("${env.ANSIBLE_DIR}") {
          withCredentials([string(credentialsId: "${env.FGT_TOKEN_CRED}", variable: 'FGT_TOKEN')]) {
            sh """
              ansible-playbook -i ${ANSIBLE_INV} playbooks/ops_apply.yml \
                --extra-vars "fgt_token=${FGT_TOKEN}"
            """
          }
        }
      }
    }
  }

  post {
    always {
      dir("${env.TF_DIR}") {
        sh 'terraform version || true'
      }
      cleanWs(cleanWhenFailure: false)
    }
  }
}

