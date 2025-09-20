# 🚀 Quick Start Guide - E-commerce Frontend Infrastructure

This guide will help you deploy your AWS infrastructure with the e-commerce frontend server in under 10 minutes.

## 📋 Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured (`aws configure`)
3. **Terraform** installed (>= 1.5)
4. **SSH Key Pair** named "project" in your AWS account

### Create SSH Key Pair (if not exists)
```bash
# Create key pair in AWS Console or via CLI
aws ec2 create-key-pair --key-name project --query 'KeyMaterial' --output text > ~/.ssh/project.pem
chmod 400 ~/.ssh/project.pem
```

## 🛠️ Deployment Steps

### 1. Download and Setup Files
```bash
# Create project directory
mkdir terraform-ecommerce-infrastructure
cd terraform-ecommerce-infrastructure

# Copy all the artifact files to this directory
# (Copy each file content from the artifacts above)
```

### 2. Configure Variables
```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Required changes in terraform.tfvars:**
```hcl
# Update these values
aws_region     = "us-east-1"              # Your preferred region
aws_account_id = "123456789012"           # Your AWS account ID
project_name   = "my-ecommerce"           # Your project name
key_pair_name  = "project"                # Your key pair name

# Security: Update SSH access (IMPORTANT!)
allowed_ssh_cidrs = [
  "203.0.113.0/24"  # Replace with your IP/network
]
```

### 3. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment (review resources)
terraform plan

# Apply configuration
terraform apply
# Type 'yes' when prompted
```

## 🔗 Access Your Server

### Get Connection Information
```bash
# SSH connection command
terraform output ecommerce_frontend_ssh_connection

# Get all URLs
terraform output ecommerce_frontend_urls

# Get instance details
terraform output ecommerce_frontend_public_ip
```

### Connect to Server
```bash
# Use the SSH command from output, or:
ssh -i ~/.ssh/project.pem ubuntu@$(terraform output -raw ecommerce_frontend_public_ip)
```

## 🖥️ Start Development

### 1. Verify Installation
```bash
# Check installed software
docker --version
terraform version
kubectl version --client
node --version
aws --version
```

### 2. Deploy Your Frontend
```bash
# Navigate to project directory
cd ~/projects/my-ecommerce/frontend

# Clone your repository
git clone https://github.com/yourusername/your-frontend-repo.git .

# Install dependencies
npm install
# or
yarn install

# Start development server
npm start
# Access at: http://<your-server-ip>:3000
```

### 3. Docker Deployment
```bash
# Create a simple Dockerfile (example)
cat > Dockerfile << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 80
CMD ["npm", "start"]
EOF

# Build and run
docker build -t ecommerce-frontend .
docker run -d -p 80:80 --name frontend ecommerce-frontend

# Access at: http://<your-server-ip>
```

## 🔍 Monitoring and Management

### CloudWatch Monitoring
- CPU utilization alarms automatically configured
- Status check monitoring enabled
- Log groups created for system logs

### Useful Commands
```bash
# Check running containers
docker ps

# View system resources
htop

# Check services
systemctl status docker

# View logs
journalctl -u docker
tail -f /var/log/syslog
```

## 🛡️ Security Best Practices

### 1. Restrict SSH Access
```bash
# Update security group to limit SSH access
# Edit terraform.tfvars and update allowed_ssh_cidrs
# Then run: terraform apply
```

### 2. Update System
```bash
# Keep system updated
sudo apt update && sudo apt upgrade -y
```

### 3. Monitor Resource Usage
```bash
# Check disk usage
df -h

# Check memory usage
free -h

# Check running processes
ps aux | head -20
```

## 🔧 Troubleshooting

### Common Issues

1. **SSH Connection Refused**
   - Check security group allows your IP
   - Verify key pair permissions: `chmod 400 ~/.ssh/project.pem`
   - Ensure instance is running: `terraform output ecommerce_frontend_instance_id`

2. **Application Not Accessible**
   - Check if service is running: `docker ps` or `pm2 list`
   - Verify port is open in security group
   - Check UFW status: `sudo ufw status`

3. **Docker Issues**
   - Restart Docker: `sudo systemctl restart docker`
   - Check Docker logs: `docker logs <container_name>`

4. **Out of Disk Space**
   - Check usage: `df -h`
   - Clean Docker: `docker system prune -a`
   - Clean apt cache: `sudo apt autoremove && sudo apt autoclean`

### Getting Help
```bash
# Check system status
sudo systemctl status docker
sudo systemctl status amazon-cloudwatch-agent

# View installation logs
sudo tail -f /var/log/user-data.log

# Check network connectivity
ping -c 4 google.com
```

## 🧹 Cleanup

When you're done testing:
```bash
# Destroy all resources
terraform destroy
# Type 'yes' when prompted

# This will delete:
# - EC2 instance
# - Security groups
# - VPC and all networking
# - CloudWatch alarms
```

## 📚 Next Steps

1. **Setup Domain**: Point your domain to the Elastic IP
2. **SSL Certificate**: Use AWS Certificate Manager or Let's Encrypt
3. **Load Balancer**: Add ALB for high availability
4. **Database**: Deploy RDS for your backend
5. **CI/CD**: Setup automated deployments with GitHub Actions
6. **Monitoring**: Enhanced monitoring with CloudWatch dashboards

## 🆘 Support

If you encounter issues:
1. Check AWS CloudFormation events
2. Review Terraform state: `terraform show`
3. Check EC2 instance logs in AWS Console
4. Verify IAM permissions for your AWS user

Happy coding! 🎉
