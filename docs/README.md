# DevOps AWS Infrastructure Project

This project demonstrates **Infrastructure as Code (IaC)** on **AWS** with **Terraform** and **configuration management** with **Ansible**.

- **Terraform** – provisions AWS infrastructure:
  - VPC with 2 public and 2 private subnets
  - Internet Gateway and route tables
  - EC2 instance (Ubuntu) in a public subnet
  - Security groups for SSH/HTTP and for the ALB
  - Application Load Balancer (ALB) with target group and listener
  - Key pair for secure SSH access
- **Ansible** – configures the EC2 instance:
  - Installs Docker
  - Pulls a Flask image from Docker Hub
  - Runs the container (port **80 → 5000**)
  - Ensures the service stays running

---

## Prerequisites

- **Ubuntu 22.04** (local machine or VM)
- **AWS account**

---

## Setup

### 1) Clone the repository

```bash
git clone https://github.com/<your-username>/devops-infra-aws.git
cd devops-infra-aws
```

### 2) Install dependencies

**Terraform**

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
```

**AWS CLI**

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Ansible**

```bash
sudo apt update
sudo apt install -y ansible
```

---

## AWS configuration

### 3) Configure credentials

Create an IAM user with **programmatic access** and attach these policies:

- `AmazonEC2FullAccess`
- `AmazonVPCFullAccess`
- `ElasticLoadBalancingFullAccess`

Then configure locally:

```bash
aws configure
# AWS Access Key ID: <from CSV>
# AWS Secret Access Key: <from CSV>
# Default region name: eu-central-1  
# Default output format: json
```

---

### 4) Prepare SSH key pair

1. In AWS Console → **EC2 → Network & Security → Key pairs** → **Create key pair**
   - Name: `devops-key-pair`
   - Type: **RSA**
   - File format: **.pem**
   - Download the `.pem` file.
2. Place it in the repo root under `.ssh/` and secure permissions:

```bash
mkdir -p .ssh
mv /path/to/devops-key-pair.pem .ssh/
chmod 400 .ssh/devops-key-pair.pem
```

3. Generate a public key **from** the PEM so Terraform can upload it:

```bash
ssh-keygen -y -f .ssh/devops-key-pair.pem > .ssh/devops-key-pair.pub
```

## Terraform infrastructure

### 5) Initialize

```bash
cd terraform
terraform init
```

### 6) Plan & apply

```bash
terraform plan
terraform apply
```

Terraform will create:

- VPC, subnets, IGW, route tables
- Security groups
- EC2 instance + key pair
- ALB with target group & HTTP listener

**Outputs** will include:

- `ec2_public_ips` – after `terraform apply` shows IP of EC2 machine.
- `alb_dns_name` – after `terraform apply` shows DNS of EC2 machine 

---

## Ansible configuration

### 7) Update inventory with your EC2 IP

After `terraform apply`, obtain the IP from the `ec2_public_ips` output and insert it in the place of \<EC2\_PUBLIC\_IP>.

```yaml
all:
  hosts:
    ec2:
      ansible_host: <EC2_PUBLIC_IP>
      ansible_user: ubuntu
      ansible_ssh_private_key_file: .ssh/devops-key-pair.pem
```

### 8) Run the playbook

```bash
ansible-playbook -i ansible/inventory.yaml ansible/playbook.yaml
```

This will install Docker, pull the Flask image from Docker Hub, and run it mapping port **80:5000**.

---

## Verification

### 9) Test the app through the ALB

Use the DNS from the `alb_dns_name` Terraform output (visible right after `apply`, or via `terraform output alb_dns_name`):

```bash
curl http://<ALB_DNS_NAME>/
curl http://<ALB_DNS_NAME>/healthz
curl http://<ALB_DNS_NAME>/readyz
```

Expected:

- `/` → `DevOps CI/CD Pipeline`
- `/healthz` and `/readyz` → HTTP **204**

## Cleanup

### 10) Tear down the stack

```bash
cd terraform
terraform destroy
```

This removes the ALB, EC2, networking (VPC/subnets/route tables), and security groups created by this project.

###

