#!/bin/bash

# =============================================================================
# FULL INSTALLATION SCRIPT FOR E-COMMERCE FRONTEND SERVER
# This script is downloaded and executed by the minimal user-data script
# =============================================================================

set -e

# Get environment variables passed from user-data
PROJECT_NAME=${PROJECT_NAME:-"devops"}
ENVIRONMENT=${ENVIRONMENT:-"dev"}
TERRAFORM_VERSION=${TERRAFORM_VERSION:-"1.6.6"}

echo "$(date): Starting full installation script"
echo "Project: $PROJECT_NAME, Environment: $ENVIRONMENT"

# Function to check if command succeeded
check_success() {
    if [ $? -eq 0 ]; then
        echo "$(date): ✅ $1 completed successfully"
    else
        echo "$(date): ❌ $1 failed"
        return 1
    fi
}

# Update system
echo "$(date): Updating system packages..."
apt-get update -y
apt-get upgrade -y
check_success "System update"

# Install essential packages
echo "$(date): Installing essential packages..."
apt-get install -y \
    curl wget git unzip software-properties-common apt-transport-https \
    ca-certificates gnupg lsb-release htop tree vim nano jq build-essential ufw
check_success "Essential packages installation"

# =============================================================================
# INSTALL DOCKER
# =============================================================================
echo "$(date): Installing Docker..."

apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
check_success "Docker installation"

# =============================================================================
# INSTALL TERRAFORM
# =============================================================================
echo "$(date): Installing Terraform..."

cd /tmp
wget https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
check_success "Terraform installation"

# =============================================================================
# INSTALL KUBECTL
# =============================================================================
echo "$(date): Installing kubectl..."

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
check_success "kubectl installation"

# =============================================================================
# INSTALL AWS CLI v2
# =============================================================================
echo "$(date): Installing AWS CLI..."

cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip
check_success "AWS CLI installation"

# =============================================================================
# INSTALL NODE.JS AND NPM
# =============================================================================
echo "$(date): Installing Node.js..."

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
npm install -g yarn pm2
check_success "Node.js installation"

# =============================================================================
# INSTALL HELM
# =============================================================================
echo "$(date): Installing Helm..."

cd /tmp
curl https://get.helm.sh/helm-v3.13.0-linux-amd64.tar.gz -o helm.tar.gz
tar -zxvf helm.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 helm.tar.gz
check_success "Helm installation"

# =============================================================================
# INSTALL K9S
# =============================================================================
echo "$(date): Installing k9s..."

cd /tmp
wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
mv k9s /usr/local/bin/
rm k9s_Linux_amd64.tar.gz
check_success "k9s installation"

# =============================================================================
# SETUP PROJECT DIRECTORIES
# =============================================================================
echo "$(date): Setting up project directories..."

mkdir -p /home/ubuntu/projects
mkdir -p /home/ubuntu/projects/$PROJECT_NAME
mkdir -p /home/ubuntu/projects/$PROJECT_NAME/frontend
mkdir -p /home/ubuntu/projects/$PROJECT_NAME/terraform
mkdir -p /home/ubuntu/projects/$PROJECT_NAME/kubernetes
chown -R ubuntu:ubuntu /home/ubuntu/projects
check_success "Project directories setup"

# =============================================================================
# SETUP BASH ENVIRONMENT
# =============================================================================
echo "$(date): Setting up bash environment..."

cat >> /home/ubuntu/.bashrc << 'EOF'

# Development aliases
alias ll='ls -alF'
alias tf='terraform'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias dps='docker ps'
alias dpa='docker ps -a'

# Environment variables
export PROJECT_NAME=$PROJECT_NAME
export ENVIRONMENT=$ENVIRONMENT
export PATH=$PATH:/usr/local/bin

echo "🚀 Welcome to $PROJECT_NAME E-commerce Frontend Server ($ENVIRONMENT)"
echo "📁 Project directory: ~/projects/$PROJECT_NAME"
EOF

chown ubuntu:ubuntu /home/ubuntu/.bashrc
check_success "Bash environment setup"

# =============================================================================
# SETUP BASH COMPLETION
# =============================================================================
echo "$(date): Setting up bash completion..."

kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null
terraform -install-autocomplete 2>/dev/null || true
helm completion bash | tee /etc/bash_completion.d/helm > /dev/null
check_success "Bash completion setup"

# =============================================================================
# CONFIGURE FIREWALL
# =============================================================================
echo "$(date): Configuring firewall..."

ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3000/tcp
ufw allow 3001/tcp
ufw allow 8000:8099/tcp
ufw allow 8080/tcp
check_success "Firewall configuration"

# =============================================================================
# CREATE WELCOME MESSAGE
# =============================================================================
echo "$(date): Creating welcome message..."

cat > /etc/motd << EOF
================================================================================
        $PROJECT_NAME E-commerce Frontend Server ($ENVIRONMENT)
================================================================================

🚀 Installed Software:
- Docker & Docker Compose (Latest)
- Terraform v$TERRAFORM_VERSION
- kubectl (Latest)
- AWS CLI v2
- Node.js v20 & npm
- Yarn & PM2
- Helm v3.13.0
- k9s (Latest)

⚡ Quick Commands:
- tf       : terraform
- k        : kubectl  
- kgp      : kubectl get pods
- dps      : docker ps

📁 Project Directory: /home/ubuntu/projects/$PROJECT_NAME/

Happy coding! 🛒✨
================================================================================
EOF

check_success "Welcome message creation"

# =============================================================================
# FINAL CLEANUP
# =============================================================================
echo "$(date): Final cleanup..."

apt-get autoremove -y
apt-get autoclean
updatedb

# Verify installations
echo "$(date): Verifying installations..."
echo "Docker: $(docker --version 2>/dev/null || echo 'FAILED')"
echo "Terraform: $(terraform version 2>/dev/null | head -1 || echo 'FAILED')"
echo "kubectl: $(kubectl version --client --short 2>/dev/null || echo 'FAILED')"
echo "Node.js: $(node --version 2>/dev/null || echo 'FAILED')"
echo "AWS CLI: $(aws --version 2>/dev/null || echo 'FAILED')"
echo "Helm: $(helm version --short 2>/dev/null || echo 'FAILED')"

touch /tmp/full-install-completed
echo "$(date): ✅ Full installation completed successfully!"
echo "$(date): 🔄 Please logout and login again to apply group memberships"
