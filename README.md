# AWS DevOps Infrastructure

## Overview

This project demonstrates automated infrastructure deployment on AWS using Infrastructure as Code. Single script deploys a full application stack with database, load balancing, and monitoring.

The infrastructure uses **Terraform** to provision resources and **Ansible** for server configuration.

**Tech Stack:** Flask · Docker · Terraform · Ansible · AWS (EC2, RDS (PostgreSQL), ALB, VPC, S3, CloudWatch, Secrets Manager) · Bash

## Key Features

- Terraform provisions complete AWS infrastructure (EC2, RDS (PostgreSQL), ALB, VPC, S3, CloudWatch, Secrets Manager)
- Bash setup script deploys entire stack with a single command
- VPC separates public subnets for application and private subnets for database
- Application Load Balancer distributes traffic to EC2 instances
- RDS PostgreSQL provides database with 7-day automated backups and sample data
- Database credentials are stored in AWS Secrets Manager
- Ansible configures EC2 instances and deploys Dockerized application
- CloudWatch monitoring with automated alerts for:
  - RDS CPU utilization above 80%
  - RDS storage below 2GB
  - EC2 CPU utilization above 80%
  - Unhealthy application instances
- Security groups control network access between components
- S3 bucket stores Terraform state with enabled versioning

## Prerequisites

- Ubuntu 20.04+
- 2GB+ RAM 
- AWS Account

## Setup

### 1. Create IAM User

1. AWS Console -> **IAM** -> **Users** -> **Create user**
2. Enter user name (e.g. `terraform-user`)
3. Click **Next**
4. Select **Attach policies directly** and attach:
   - AmazonEC2FullAccess
   - AmazonVPCFullAccess
   - ElasticLoadBalancingFullAccess
   - AmazonRDSFullAccess
   - AmazonS3FullAccess
   - SecretsManagerReadWrite
   - CloudWatchFullAccess
   - IAMFullAccess
5. Click **Next** -> **Create user**

### 2. Create Access Keys

1. Click on the created user name
2. Go to **Security credentials** tab
3. Scroll to **Access keys** section -> **Create access key**
4. Select **Other** as use case -> **Next**
5. **Create access key**
6. **Download .csv file** (contains Access Key ID and Secret Access Key)

### 3. Clone Repository
```bash
git clone https://github.com/adrian-wisniewski-it/devops-infra-aws.git
cd devops-infra-aws
```

### 4. Run Setup
```bash
sudo bash scripts/setup.sh
```

During setup, you will be prompted to:
- Configure AWS credentials (enter Access Key ID and Secret Access Key from CSV file, region: `eu-central-1`, format: `json`)
- Confirm Terraform deployment by typing `yes`

The script will automatically provision all AWS infrastructure and deploy the application.