pipeline {
  agent any

  environment {
    TF_PATH     = "${env.WORKSPACE}/terraform"
    SCRIPTS     = "${env.WORKSPACE}/scripts"
    TFSEC_OUT   = "${env.WORKSPACE}/tfsec-report.json"
    CHECKOV_OUT = "${env.WORKSPACE}/checkov-report.json"
    TF_PLAN_OUT = "${env.WORKSPACE}/plan.out"

    NULL_DEVICE = "/dev/null"
  }

  options {
    timestamps()
    ansiColor('xterm')
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
  }

  stages {
    stage('Checkout') {
      steps {
        echo "📦 Checking out repository"
        checkout scm
      }
    }

    stage('Prepare Tools') {
      steps {
        echo "🧰 Ensure Terraform, tfsec and checkov are available on agent"
        sh '''
          set -e
          # terraform - prefer preinstalled on agent; install if missing (requires apt/unzip)
          if ! command -v terraform >"${NULL_DEVICE}" 2>&1; then
            echo "Terraform not found - installing"
            sudo apt-get update -y
            sudo apt-get install -y wget unzip
            sudo wget -q https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
            sudo unzip terraform_1.6.6_linux_amd64.zip -d /usr/local/bin/
            terraform -version
          fi

          # pip for checkov
          if ! command -v pip3 >"${NULL_DEVICE}" 2>&1; then
            apt-get install -y python3-pip
          fi
        '''
      }
    }

    stage('Terraform Init & Validate') {
      steps {
        dir("${TF_PATH}") {
          sh '''bash -c "
            set -e
            terraform init -input=false
            terraform validate
            terraform fmt -check
          "'''
        }
      }
    }

    stage('Security Scan - tfsec') {
      steps {
        sh '''bash -c "
        chmod +x ${SCRIPTS}/run_tfsec.sh
        "${SCRIPTS}/run_tfsec.sh"
        "'''
        archiveArtifacts artifacts: 'tfsec-report.json', fingerprint: true, allowEmptyArchive: false
      }
    }

    stage('Security Scan - Checkov') {
      steps {
        sh '''bash -c " 
        chmod +x "${SCRIPTS}/run_checkov.sh"
        "${SCRIPTS}/run_checkov.sh"
        "'''
        archiveArtifacts artifacts: 'checkov-report.json', fingerprint: true, allowEmptyArchive: false
      }
    }

    stage('Terraform Plan') {
      steps {
        sh '''bash -c "
        chmod +x "${SCRIPTS}/terraform_plan.sh"
        sh "${SCRIPTS}/terraform_plan.sh"
        "'''
        archiveArtifacts artifacts: 'plan.out', fingerprint: true, allowEmptyArchive: false
      }
    }

    stage('Manual Approval & Apply (optional)') {
      when {
          expression { return env.DEPLOY == "true" }
      }
      steps {
        echo "🔐 Running terraform apply (DEPLOY=true)"
        // Use AWS creds stored in Jenkins (see README to configure)
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
          sh "chmod +x ${SCRIPTS}/terraform_apply.sh"
          sh "${SCRIPTS}/terraform_apply.sh"
        }
      }
    }
  }

  post {
    always {
      echo '🧹 Cleaning workspace'
      cleanWs()
    }
    success {
      echo '✅ Pipeline finished successfully'
    }
    failure {
      echo '❌ Pipeline failed - check console output and archived reports'
    }
  }
}
