#!/bin/bash
# =============================================================================
# USER DATA SCRIPT FOR E-COMMERCE FRONTEND SERVER
# Ubuntu 24.04 LTS - Install Docker, Terraform, kubectl
# =============================================================================

# Update system
apt-get update -y
apt-get upgrade -y

# Install essential packages
apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    htop \
    tree \
    vim \
    nano \
    jq \
    build-essential

# =============================================================================
# INSTALL DOCKER
# =============================================================================
echo "Installing Docker..."

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $$(. /etc/os-release && echo \"$${VERSION_CODENAME}\") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index
apt-get update -y

# Install Docker Engine, containerd, and Docker Compose
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Verify Docker installation
docker --version
docker compose version

# =============================================================================
# INSTALL TERRAFORM
# =============================================================================
echo "Installing Terraform..."

# Download and install Terraform
TERRAFORM_VERSION="${terraform_version}"
wget https://releases.hashicorp.com/terraform/$${TERRAFORM_VERSION}/terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_$${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_$${TERRAFORM_VERSION}_linux_amd64.zip

# Verify Terraform installation
terraform version

# =============================================================================
# INSTALL KUBECTL
# =============================================================================
echo "Installing kubectl..."

# Download kubectl
curl -LO "https://dl.k8s.io/release/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

# Verify kubectl installation
kubectl version --client

# =============================================================================
# INSTALL AWS CLI v2
# =============================================================================
echo "Installing AWS CLI v2..."

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Verify AWS CLI installation
aws --version

# =============================================================================
# INSTALL NODE.JS AND NPM (for frontend development)
# =============================================================================
echo "Installing Node.js and npm..."

# Install NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# Install Node.js
apt-get install -y nodejs

# Verify installation
node --version
npm --version

# Install Yarn package manager
npm install -g yarn

# Install PM2 for process management
npm install -g pm2

# =============================================================================
# INSTALL ADDITIONAL TOOLS
# =============================================================================
echo "Installing additional development tools..."

# Install Helm (Kubernetes package manager)
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update -y
apt-get install -y helm

# Install k9s (Kubernetes CLI management tool)
wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
mv k9s /usr/local/bin/
rm k9s_Linux_amd64.tar.gz

# Install kubectx and kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# =============================================================================
# SETUP DIRECTORIES AND PERMISSIONS
# =============================================================================
echo "Setting up directories and permissions..."

# Create project directories
mkdir -p /home/ubuntu/projects
mkdir -p /home/ubuntu/projects/${project_name}
mkdir -p /home/ubuntu/projects/${project_name}/frontend
mkdir -p /home/ubuntu/projects/${project_name}/terraform
mkdir -p /home/ubuntu/projects/${project_name}/kubernetes

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/projects

# Create useful aliases
cat >> /home/ubuntu/.bashrc << 'EOF'

# Custom aliases for development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias tf='terraform'
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias docker-stop-all='docker stop $$(docker ps -aq)'
alias docker-rm-all='docker rm $$(docker ps -aq)'
alias docker-rmi-all='docker rmi $$(docker images -q)'

# Environment variables
export PROJECT_NAME=${project_name}
export ENVIRONMENT=${environment}
export KUBECONFIG=/home/ubuntu/.kube/config

# Add local bin to PATH
export PATH=$$PATH:/home/ubuntu/.local/bin
EOF

# =============================================================================
# SETUP BASH COMPLETION
# =============================================================================
echo "Setting up bash completion..."

# kubectl completion
kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null

# terraform completion
terraform -install-autocomplete 2>/dev/null || true

# helm completion
helm completion bash | tee /etc/bash_completion.d/helm > /dev/null

# =============================================================================
# CONFIGURE FIREWALL (UFW)
# =============================================================================
echo "Configuring firewall..."

# Enable UFW
ufw --force enable

# Allow SSH
ufw allow 22/tcp

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Allow common development ports
ufw allow 3000/tcp  # React dev server
ufw allow 3001/tcp  # Next.js
ufw allow 8000:8099/tcp  # Docker containers
ufw allow 8080/tcp  # Nginx/Alternative HTTP

# =============================================================================
# SETUP MONITORING AND LOGGING
# =============================================================================
echo "Setting up monitoring..."

# Install and start Amazon CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb
rm amazon-cloudwatch-agent.deb

# Create CloudWatch config
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << CLOUDWATCH_EOF
{
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/syslog",
                        "log_group_name": "/aws/ec2/${project_name}-${environment}/syslog"
                    }
                ]
            }
        }
    }
}
CLOUDWATCH_EOF

# =============================================================================
# FINAL SETUP
# =============================================================================
echo "Finalizing setup..."

# Update locate database
updatedb

# Create a welcome message
cat > /etc/motd << MOTD_EOF
================================================================================
        ${project_name} E-commerce Frontend Server (${environment})
================================================================================

Installed Software:
- Docker & Docker Compose
- Terraform v${terraform_version}
- kubectl (latest)
- AWS CLI v2
- Node.js v20 & npm
- Helm & k9s
- PM2 Process Manager

Useful Commands:
- tf      : terraform alias
- k       : kubectl alias
- kgp     : kubectl get pods
- kgs     : kubectl get services

Project Directory: /home/ubuntu/projects/${project_name}

Happy coding! 🚀
================================================================================
MOTD_EOF

# Set proper permissions for ubuntu user files
chown ubuntu:ubuntu /home/ubuntu/.bashrc

# Cleanup
apt-get autoremove -y
apt-get autoclean

# Log completion
echo "$$(date): User data script completed successfully" >> /var/log/user-data.log

# Reboot to ensure all services are running properly
echo "Setup completed! System will reboot in 30 seconds..."
sleep 30
reboot
