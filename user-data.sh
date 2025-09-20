#!/bin/bash

# =============================================================================
# MINIMAL USER DATA SCRIPT - Downloads and executes full installation script
# =============================================================================

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "$(date): Starting minimal user-data script"
echo "Project: ${project_name}, Environment: ${environment}"

# Update system and install curl if needed
apt-get update -y
apt-get install -y curl wget

# Download and execute the full installation script
echo "$(date): Downloading full installation script..."
cd /tmp
curl -o full-install.sh https://raw.githubusercontent.com/YOUR_USERNAME/terraform-ecommerce-infrastructure/main/scripts/full-install.sh

if [ $? -eq 0 ]; then
    echo "$(date): Running full installation script..."
    chmod +x full-install.sh
    PROJECT_NAME="${project_name}" ENVIRONMENT="${environment}" TERRAFORM_VERSION="${terraform_version}" ./full-install.sh
else
    echo "$(date): Failed to download installation script, running basic setup..."
    
    # Basic software installation as fallback
    apt-get install -y docker.io git nodejs npm
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    
    # Install Terraform
    cd /tmp
    wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
    unzip terraform_${terraform_version}_linux_amd64.zip
    mv terraform /usr/local/bin/
    
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    
    echo "$(date): Basic installation completed"
fi

echo "$(date): User-data script completed"
touch /tmp/user-data-completed
