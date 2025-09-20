# =============================================================================
# VARIABLES
# =============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format: us-west-2, eu-west-1, etc."
  }
}

variable "project_name" {
  description = "Name of the project - used for resource naming (lowercase)"
  type        = string
  default     = "devops"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project_display_name" {
  description = "Display name of the project for tags and descriptions"
  type        = string
  default     = "DevOps"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_account_id" {
  description = "AWS Account ID for additional security and validation"
  type        = string
  default     = "642959137314"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "AWS Account ID must be a 12-digit number."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = []
}

# =============================================================================
# ADDITIONAL VARIABLES FOR MODULARITY
# =============================================================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address"
  type        = bool
  default     = true
}

# =============================================================================
# EC2 VARIABLES
# =============================================================================

variable "create_ecommerce_server" {
  description = "Whether to create the e-commerce frontend server"
  type        = bool
  default     = true
}

variable "ecommerce_instance_type" {
  description = "EC2 instance type for e-commerce frontend server"
  type        = string
  default     = "t2.large"

  validation {
    condition = contains([
      "t2.micro", "t2.small", "t2.medium", "t2.large", "t2.xlarge", "t2.2xlarge",
      "t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge",
      "m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge"
    ], var.ecommerce_instance_type)
    error_message = "Instance type must be a valid EC2 instance type."
  }
}

variable "ecommerce_ami_id" {
  description = "AMI ID for e-commerce frontend server (Ubuntu 24.04 LTS)"
  type        = string
  default     = "ami-0360c520857e3138f"
}

variable "ecommerce_volume_size" {
  description = "Root volume size in GiB for e-commerce server"
  type        = number
  default     = 30

  validation {
    condition     = var.ecommerce_volume_size >= 8 && var.ecommerce_volume_size <= 1000
    error_message = "Volume size must be between 8 and 1000 GiB."
  }
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for EC2 instances"
  type        = string
  default     = "project"
}

variable "ecommerce_subnet_type" {
  description = "Type of subnet to deploy e-commerce server (public or private)"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.ecommerce_subnet_type)
    error_message = "Subnet type must be either 'public' or 'private'."
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = false
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH to the e-commerce server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
