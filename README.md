# AWS Infrastructure with Terraform - Modular Structure

This repository contains Terraform configuration for AWS infrastructure organized in a modular structure following best practices, including a fully configured e-commerce frontend server.

## 📁 File Structure

```
.
├── versions.tf              # Terraform and provider version requirements
├── providers.tf             # Provider configurations
├── variables.tf             # Input variable definitions
├── locals.tf               # Local values and calculations
├── data.tf                 # Data source definitions
├── vpc.tf                  # VPC and networking resources
├── security-groups.tf      # Security group definitions
├── ec2.tf                  # EC2 instances and related resources
├── user-data.sh            # User data script for EC2 initialization
├── outputs.tf              # Output value definitions
├── terraform.tfvars.example # Example variable values
└── README.md               # This file
```

## 🏗️ Infrastructure Components

### Core Networking
- **VPC**: Main virtual private cloud with configurable CIDR
- **Subnets**: Public, private, and database subnets across multiple AZs
- **Internet Gateway**: For public internet access
- **NAT Gateways**: Optional for private subnet outbound internet access
- **Route Tables**: Separate routing for each subnet tier

### E-commerce Frontend Server
- **EC2 Instance**: Ubuntu 24.04 LTS with t2.large instance type
- **Pre-installed Software**: Docker, Terraform, kubectl, AWS CLI, Node.js
- **Development Tools**: PM2, Helm, k9s, kubectx/kubens
- **Security**: Dedicated security group with controlled access
- **Monitoring**: CloudWatch alarms for CPU and status monitoring
- **Storage**: 30 GiB encrypted EBS volume

### Security Groups
- **ALB Security Group**: For Application Load Balancers
- **Application Security Group**: For application servers
- **Database Security Group**: For database instances
- **Bastion Security Group**: For bastion hosts
- **EFS Security Group**: For Elastic File System
- **ElastiCache Security Group**: For caching services
- **E-commerce Frontend Security Group**: For the frontend server

### Features
- **Multi-AZ Support**: Automatically distributes resources across availability zones
- **Environment-aware**: Different configurations for dev/staging/prod
- **Account Validation**: Prevents deployment to wrong AWS accounts
- **Flexible Subnetting**: Automatic CIDR calculation
- **Comprehensive Tagging**: Consistent resource tagging strategy

## 🚀 Quick Start

### Prerequisites
- Terraform >= 1.5
- AWS CLI configured
- AWS Key Pair named "project" (or customize the name)
- Appropriate AWS permissions

### Create SSH Key Pair (if not exists)
```bash
# Create key pair in AWS Console or via CLI
aws ec2 create-key-pair --key-name project --query 'KeyMaterial' --output text > ~/.ssh/project.pem
chmod 400 ~/.ssh/project.pem
```

### Deployment Steps

1. **Clone and prepare**:
   ```bash
   mkdir terraform-ecommerce-infrastructure
   cd terraform-ecommerce-infrastructure
   # Copy all the files from the artifacts above
   ```

2. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan deployment**:
   ```bash
   terraform plan
   ```

5. **Apply configuration**:
   ```bash
   terraform apply
   ```

## ⚙️ Configuration

### Required Variables
- `aws_region`: AWS region for deployment
- `aws_account_id`: Your AWS account ID for validation
- `project_name`: Project identifier (lowercase)
- `environment`: Environment name (dev/staging/prod)
- `key_pair_name`: AWS key pair name for EC2 access

### Optional Variables
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)
- `availability_zones`: Specific AZs to use (defaults to first 3 available)
- `enable_nat_gateway`: Enable NAT gateways for private subnets (default: false)
- `single_nat_gateway`: Use single NAT gateway vs one per AZ (default: true)
- `enable_vpn_gateway`: Enable VPN gateway (default: false)
- `create_ecommerce_server`: Create e-commerce frontend server (default: true)
- `ecommerce_instance_type`: EC2 instance type (default: t2.large)
- `ecommerce_ami_id`: AMI ID for Ubuntu 24.04 LTS (default: ami-0360c520857e3138f)
- `ecommerce_volume_size`: Root volume size in GiB (default: 30)
- `ecommerce_subnet_type`: Deploy in public or private subnet (default: public)

### E-commerce Server Configuration

The e-commerce frontend server comes pre-configured with:

#### Pre-installed Software
- **Docker & Docker Compose**: Container management
- **Terraform v1.6.6**: Infrastructure as code
- **kubectl**: Kubernetes command-line tool
- **AWS CLI v2**: AWS command-line interface
- **Node.js v20 & npm**: JavaScript runtime and package manager
- **Yarn**: Alternative package manager
- **PM2**: Process manager for Node.js applications

#### Development Tools
- **Helm**: Kubernetes package manager
- **k9s**: Kubernetes cluster management tool
- **kubectx/kubens**: Kubernetes context and namespace switcher
- **Git, curl, wget, jq**: Essential development utilities

#### Useful Aliases
- `tf` → `terraform`
- `k` → `kubectl`
- `kgp` → `kubectl get pods`
- `kgs` → `kubectl get services`
- `kgd` → `kubectl get deployments`

#### Project Structure
```
/home/ubuntu/projects/
└── <project_name>/
    ├── frontend/     # Frontend application code
    ├── terraform/    # Infrastructure code
    └── kubernetes/   # Kubernetes manifests
```

### Environment-Specific Configurations

The infrastructure automatically adjusts based on the environment:

| Environment | Instance Type | Min Size | Max Size | Desired Size |
|------------|---------------|----------|----------|--------------|
| dev        | t3.micro      | 1        | 3        | 1            |
| staging    | t3.small      | 1        | 5        | 2            |
| prod       | t3.medium     | 2        | 10       | 3            |

## 🖥️ Connecting to Your E-commerce Server

After deployment, you can connect to your e-commerce frontend server:

### SSH Connection
```bash
# Get the SSH command from Terraform output
terraform output ecommerce_frontend_ssh_connection

# Or connect manually
ssh -i ~/.ssh/project.pem ubuntu@<public_ip>
```

### Application URLs
```bash
# Get all available URLs
terraform output ecommerce_frontend_urls

# Access your applications
http://<public_ip>        # HTTP
https://<public_ip>       # HTTPS  
http://<public_ip>:3000   # React dev server
http://<public_ip>:3001   # Next.js application
```

### First Steps After Connection

1. **Verify installations**:
   ```bash
   docker --version
   terraform version
   kubectl version --client
   node --version
   npm --version
   ```

2. **Start your development**:
   ```bash
   cd ~/projects/<project_name>/frontend
   # Clone your frontend repository
   git clone <your-repo-url> .
   # Install dependencies and start development
   npm install
   npm start
   ```

3. **Container development**:
   ```bash
   # Build and run your application in Docker
   docker build -t ecommerce-frontend .
   docker run -p 80:80 ecommerce-frontend
   ```

## 🔒 Security Best Practices

### Implemented Security Measures
- **Network Segmentation**: Separate subnets for different tiers
- **Security Groups**: Principle of least privilege
- **Account Validation**: Prevents accidental deployments
- **Encrypted Storage**: EBS volumes encrypted at rest

### Security Group Rules
- **ALB**: HTTP/HTTPS from internet
- **Application**: Traffic only from ALB and bastion
- **Database**: Access only from application servers and bastion
- **Bastion**: SSH access (configure IP restrictions)
- **E-commerce Frontend**: HTTP/HTTPS from internet, SSH from specified CIDRs

### E-commerce Server Security
- **Encrypted EBS volumes**: Root volume encrypted at rest
- **Security Groups**: Controlled access to specific ports
- **UFW Firewall**: Additional host-level firewall protection
- **IMDSv2**: Instance metadata service v2 enforced
- **CloudWatch Monitoring**: CPU and status check alarms

## 📊 Outputs

The configuration provides comprehensive outputs for integration with other resources:

### Network Outputs
- VPC ID and CIDR
- Subnet IDs (public, private, database)
- Route table IDs
- NAT Gateway IDs and public IPs

### Security Outputs
- Security group IDs for all tiers
- AMI IDs for common base images

### E-commerce Server Outputs
- Instance ID, public/private IPs
- SSH connection command
- Application URLs
- Security group ID

### Metadata Outputs
- Resource naming prefix
- Common tags
- Environment configuration

## 🔄 Best Practices Implemented

### File Organization
- **Separation of Concerns**: Each file has a specific purpose
- **Logical Grouping**: Related resources grouped together
- **Clear Naming**: Descriptive file and resource names

### Resource Management
- **Lifecycle Rules**: Prevent accidental destruction of critical resources
- **Dynamic References**: Resources reference each other dynamically
- **Consistent Tagging**: All resources tagged with common metadata

### Scalability
- **Dynamic AZ Selection**: Automatically uses available zones
- **Flexible Subnetting**: CIDR blocks calculated automatically
- **Environment Awareness**: Configuration adapts to environment

## 🛠️ Customization

### Adding New Environments
1. Add environment to `validation` block in `variables.tf`
2. Add configuration in `environment_config` local in `locals.tf`
3. Update documentation

### Adding New Security Groups
1. Add resource definition in `security-groups.tf`
2. Follow naming convention: `aws_security_group.<purpose>`
3. Add output in `outputs.tf`

### Modifying Subnet Layout
1. Update CIDR calculations in `locals.tf`
2. Adjust subnet resources in `vpc.tf`
3. Update route table associations as needed

## 🚨 Important Notes

### Before Deployment
- **Update Account ID**: Change `aws_account_id` in `terraform.tfvars`
- **Create Key Pair**: Ensure the key pair exists in your AWS account
- **Review Security Groups**: Especially SSH access rules for the frontend server
- **Check Region**: Ensure you're deploying to the correct region
- **Verify AMI**: Ensure the Ubuntu 24.04 AMI ID is correct for your region

### Cost Considerations
- **EC2 Instance**: t2.large instance runs continuously (consider stopping when not in use)
- **NAT Gateways**: Incur hourly charges and data transfer costs
- **VPN Gateways**: Additional hourly charges
- **EBS Volumes**: 30 GiB encrypted storage
- **Elastic IP**: No charge when attached to running instance

### Security Warnings
- **SSH Access**: Default allows 0.0.0.0/0 - restrict to your IP ranges in `allowed_ssh_cidrs`
- **Key Pair**: Ensure you have the private key file for the specified key pair
- **Database Access**: Only accessible from application and bastion security groups
- **E-commerce Server**: Exposed ports (80, 443, 3000, 3001, 8080) are open to internet

## 📝 Next Steps

After deploying the infrastructure, you can:

### Immediate Actions
1. **Connect to E-commerce Server**: Use the SSH connection output
2. **Verify Software Installation**: Check all pre-installed tools
3. **Deploy Frontend Application**: Clone and run your e-commerce frontend
4. **Setup CI/CD**: Configure automated deployments

### Additional AWS Resources
1. **Application Load Balancer**: Using the ALB security group
2. **Auto Scaling Groups**: Using the application security group
3. **RDS Database**: Using the database subnets and security group
4. **ElastiCache**: Using the cache security group
5. **EFS**: Using the EFS security group for shared storage

### E-commerce Development Workflow
1. **Frontend Development**:
   ```bash
   # Connect to server
   ssh -i ~/.ssh/project.pem ubuntu@<public_ip>
   
   # Navigate to project directory
   cd ~/projects/<project_name>/frontend
   
   # Clone your repository
   git clone <your-frontend-repo> .
   
   # Install dependencies and start
   npm install
   npm start  # or yarn start
   ```

2. **Container Deployment**:
   ```bash
   # Build Docker image
   docker build -t ecommerce-frontend .
   
   # Run container
   docker run -d -p 80:80 --name frontend ecommerce-frontend
   ```

3. **Kubernetes Deployment** (if using Kubernetes):
   ```bash
   # Create Kubernetes manifests in ~/projects/<project_name>/kubernetes/
   kubectl apply -f ~/projects/<project_name>/kubernetes/
   ```

## 🤝 Contributing

1. Follow existing naming conventions
2. Update documentation for any changes
3. Test in development environment first
4. Add appropriate outputs for new resources

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
