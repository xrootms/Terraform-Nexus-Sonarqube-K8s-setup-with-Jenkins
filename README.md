# Automated Terraform CI/CD Pipeline with Checkov Security Scanning (Jenkins)
This project focuses on building a fully automated **Infrastructure-as-Code** deployment pipeline using Terraform, integrated with Jenkins CI/CD and Checkov security scanning.

## IaC Overview
The pipeline provisions a complete AWS infrastructure stack that includes:

- ➡️ A custom VPC with public subnets, Internet Gateway, and route tables
- ➡️ Security Groups for SonarQube, Nexus, and Kubernetes cluster nodes
- ➡️ EC2 instances for SonarQube, Nexus Repository Manager, and Kubeadm master/worker nodes (with User Data installation script)

## Pipeline Overview
The Jenkins pipeline automates the following stages:

- 1️⃣ Git Checkout - Clones the Terraform repository from GitHub using Jenkins credentials
- 2️⃣ Load tfvars - Loads environment-specific Terraform variable files securely from Jenkins credentials for use in the pipeline.
- 3️⃣ Terraform Init - Initializes Terraform modules and providers for deployment.
- 4️⃣ Checkov Security Scan  - Runs Checkov to detect Terraform misconfigurations and publishes a report.
- 5️⃣ Terraform Plan - Generates a Terraform execution plan to preview infrastructure changes.
- 6️⃣ Terraform Apply - Applies the Terraform plan to provision or update cloud infrastructure.

## Prerequisites
Before Running This project, Make sure you have the following prerequisites ready:

### Local / Developer Requirements

➡️ Terraform v1.3+ installed
➡️ AWS CLI configured with IAM user credentials (Access Key & Secret Key)
➡️ Public and Private Key
➡️ Git installed to clone the repository
➡️ Basic IAM permissions for Terraform (EC2, VPC, IAM, S3, CloudWatch)

### Jenkins Requirements

➡️ Jenkins installed on a server (EC2, VM etc.)
➡️ Required Jenkins plugins: AWS Credentials
➡️ Jenkins credentials configured for: Github, AWS kyes and terraform.tfvars file
➡️ Checkov (via pip) Installed 
➡️ Terraform v1.3+ installed

### Terraform Backend (Optional but recommended)

➡️ S3 bucket for remote backend state
➡️ DynamoDB table for state locking


### Create a Jenkins Pipeline Job*

**Path:** `Jenkins > New Item`

1. Name: `full-stack`
2. Type: `Pipeline`
3. Discard Old Builds → Keep for 100 days, max 2 builds
4. Add pipeline script:

```groovy
pipeline {
    agent any

    stages {
        stage('Git Checkout') {
            steps {
                git 'https://github.com/xrootms/Terraform-Nexus-SonarQube-Kubeadm-setup.git'
            }
        }
        stage('Load tfvars') {
            steps {
                withCredentials([file(credentialsId: 'tvars', variable: 'TFVARS')]) {
                  sh '''
                  ls -l
                  rm -f terraform.tfvars
                  ls -l
                  cp $TFVARS terraform.tfvars
                  ls -l
                  '''
                }
            }
        }
        stage('terraform init') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                  sh 'terraform init'
              }
            }
        }
        stage('Checkov Scan') {
            steps {
                catchError(buildResult: 'SUCCESS') {
                    // Run Checkov and save report directly
                    sh "checkov -d . -o junitxml --output-file-path checkov-report.xml"
                    
                    // Publish Checkov JUnit report in Jenkins
                    junit testResults: 'checkov-report.xml', skipPublishingChecks: true
                 }
                 // Archive the report
                 archiveArtifacts artifacts: 'checkov-report.xml', onlyIfSuccessful: false
             }
          }
       stage('terraform plan') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                  sh 'terraform plan -var-file=terraform.tfvars -out=tfplan'
              }
            }
        }
        /*stage('terraform Apply') {
            steps {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws-creds', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                  sh 'terraform apply -auto-approve -var-file=terraform.tfvars'
              }
            }
        }*/
        
    }
}


```



####  Clone the repo:
   ```bash
   git clone https://github.com/xrootms/Terraform-Nexus-SonarQube-Kubeadm-setup.git
   cd Terraform-Nexus-SonarQube-Kubeadm-setup
   ```

#### 2. Copy and edit variables: (Update variable values as needed — VPC, CIDR, public key, region, etc.)
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

#### 3. Initialize Terraform:
   ```bash
   terraform init
   ```

#### 4. Plan and Apply:
   ```bash
   terraform plan
   terraform apply
   ```

#### 5. Get ssh connection for EC2:

