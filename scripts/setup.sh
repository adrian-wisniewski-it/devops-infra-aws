#!/bin/bash
set -e

# Check for sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo privileges. Please run 'sudo bash scripts/setup.sh'"
    exit 1
fi

# Verify if we are in the project root directory
if [ ! -d "terraform" ] || [ ! -d "ansible" ]; then
    echo "Error: This script must be run from the project root directory."
    echo "Please cd to the main project folder."
    exit 1
fi

# Install Terraform if not already installed
if ! command -v terraform &> /dev/null; then
    echo "Terraform not found. Installing..."
    wget -qO - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
    apt update && apt install -y terraform
    echo "Terraform installed successfully."
else
    echo "Terraform is already installed. Skipping installation."
fi

echo "--------------------------------------"

# Install AWS CLI if not already installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing..."
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
    echo "AWS CLI installed successfully."
else
    echo "AWS CLI is already installed. Skipping installation."
fi

echo "--------------------------------------"

# Install Ansible if not already installed
if ! command -v ansible &> /dev/null; then
    echo "Ansible not found. Installing..."
    apt update && apt install -y ansible
    echo "Ansible installed successfully."
else
    echo "Ansible is already installed. Skipping installation."
fi

echo "--------------------------------------"

echo "Installing Ansible AWS collection..."
ansible-galaxy collection install amazon.aws --force
echo "Ansible AWS collection installed successfully."

echo "--------------------------------------"

# Configure AWS credentials if not already configured
if [ ! -f "/root/.aws/credentials" ]; then
    echo "AWS credentials not found. Please enter your AWS credentials."
    aws configure
    echo "AWS credentials configured successfully."
else
    echo "AWS credentials already configured. Skipping configuration."
fi

echo "--------------------------------------"

# Check for the presence of the SSH key pair
echo "Checking for SSH key pair..."
if [ ! -f ".ssh/devops-key-pair.pem" ]; then
    echo ""
    echo "Error: SSH private key .ssh/devops-key-pair.pem not found."
    echo "Please create a SSH key pair according to the project README and place the private key in the .ssh/ directory."
    echo ""
    exit 1
fi

# Set correct permissions for the SSH private key
echo "Found .ssh/devops-key-pair.pem"
echo "Setting correct permissions for the SSH key..."
chmod 400 .ssh/devops-key-pair.pem
echo "Permissions set successfully."

echo "--------------------------------------"

# Generate the public key from the private key if it doesn't exist
if [ ! -f ".ssh/devops-key-pair.pub" ]; then
    echo "Generating public key from private key..."
    ssh-keygen -y -f .ssh/devops-key-pair.pem > .ssh/devops-key-pair.pub
    echo "Public key generated successfully."
else
    echo "Public key already exists. Skipping generation."
fi
echo "SSH key setup complete."

echo "--------------------------------------"

# Set up Terraform S3 backend if not already configured
cd terraform
if [ -f "backend.tf" ] && ! grep -q "PLACEHOLDER" backend.tf; then
    echo "S3 bucket backend for Terraform state is already configured. Skipping setup."
    terraform init
else
    echo "Setting up S3 backend for Terraform state..."
    # Temporarily rename backend.tf to avoid errors during initial init
    mv backend.tf backend.tf.tmp
    echo "Initializing Terraform without backend..."
    terraform init
    echo "Creating S3 bucket backend for Terraform state..."
    terraform apply \
        -target=random_id.suffix \
        -target=aws_s3_bucket.tf_state_bucket \
        -target=aws_s3_bucket_versioning.tf_state_bucket_versioning
    BUCKET_NAME=$(terraform output -raw tf_state_bucket_name)
    echo "S3 bucket created: $BUCKET_NAME"
    # Update backend.tf with the actual bucket name
    sed -i "s/PLACEHOLDER/$BUCKET_NAME/" backend.tf.tmp
    mv backend.tf.tmp backend.tf
    echo "Migrating Terraform state to the new S3 backend..."
    terraform init -migrate-state -force-copy
    echo "Terraform S3 backend setup complete."  
fi

echo "--------------------------------------"

# Apply the full Terraform configuration
echo "Validating and applying Terraform configuration..."
terraform validate
terraform apply
EC2_IP=$(terraform output -raw ec2_public_ip)
DB_HOST=$(terraform output -raw db_host)
DB_NAME=$(terraform output -raw db_name)
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "Terraform configuration applied successfully."

echo "--------------------------------------"

# Update Ansible inventory with EC2 IP and DB host
echo "Updating Ansible inventory with EC2 IP and DB host..."
cd ..
if [ -f "ansible/inventory.yaml" ]; then
    sed -i "s|EC2_PUBLIC_IP|$EC2_IP|g" ansible/inventory.yaml
    sed -i "s|DB_HOST|$DB_HOST|g" ansible/inventory.yaml
    echo "Inventory updated with EC2 IP and DB host."
else
    echo "ansible/inventory.yaml not found. Please check your setup."
    exit 1
fi

echo "--------------------------------------"

# Run Ansible playbook to configure the EC2 instance
echo "Waiting for EC2 instance to be ready..."
sleep 30
echo "Running Ansible playbook to configure the EC2 instance..."
ansible-playbook -i ansible/inventory.yaml ansible/playbook.yaml
echo "Ansible playbook executed successfully."

echo "--------------------------------------"
echo ""
echo "--------------------------------------"
echo "         Setup Complete!"
echo "--------------------------------------"
echo ""
echo "Infrastructure Details:"
echo "  Application Load Balancer: http://$ALB_DNS"
echo "  EC2 Instance IP: $EC2_IP"
echo "  RDS Database Host: $DB_HOST"
echo "  RDS Database Name: $DB_NAME"
echo ""
echo "Testing the application:"
echo "  curl http://$ALB_DNS/"
echo "  curl http://$ALB_DNS/healthz"
echo "  curl http://$ALB_DNS/users"
echo "  curl http://$ALB_DNS/orders"
echo ""
echo "To clean up resources:"
echo "  Delete manually through AWS Console (RDS, EC2, ALB, VPC, S3, Secrets)"
echo "  Or use: cd terraform && terraform destroy"
echo "  Note: S3 state bucket requires manual deletion"
echo ""
echo "--------------------------------------"





