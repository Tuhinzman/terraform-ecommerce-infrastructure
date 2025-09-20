# =============================================================================
# OUTPUTS
# =============================================================================

# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = local.availability_zones
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_cidrs" {
  description = "CIDR blocks of the database subnets"
  value       = aws_subnet.database[*].cidr_block
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "database_route_table_id" {
  description = "ID of the database route table"
  value       = aws_route_table.database.id
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "application_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.application.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

output "efs_security_group_id" {
  description = "ID of the EFS security group"
  value       = aws_security_group.efs.id
}

output "elasticache_security_group_id" {
  description = "ID of the ElastiCache security group"
  value       = aws_security_group.elasticache.id
}

# Subnet Group Outputs (useful for RDS and ElastiCache)
output "database_subnet_group_name" {
  description = "Name for database subnet group (use subnet IDs to create)"
  value       = "${local.name_prefix}-database-subnet-group"
}

output "elasticache_subnet_group_name" {
  description = "Name for ElastiCache subnet group (use private subnet IDs to create)"
  value       = "${local.name_prefix}-cache-subnet-group"
}

# Environment Configuration Outputs
output "environment_config" {
  description = "Environment-specific configuration"
  value       = local.current_env_config
}

# Metadata Outputs
output "resource_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

output "aws_account_id" {
  description = "Current AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Current AWS Region"
  value       = data.aws_region.current.name
}

output "name_prefix" {
  description = "Resource naming prefix"
  value       = local.name_prefix
}

# AMI Outputs
output "amazon_linux_ami_id" {
  description = "Latest Amazon Linux 2 AMI ID"
  value       = data.aws_ami.amazon_linux.id
}

output "ubuntu_ami_id" {
  description = "Latest Ubuntu 20.04 LTS AMI ID"
  value       = data.aws_ami.ubuntu.id
}

# VPN Gateway Output (if enabled)
output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

# =============================================================================
# EC2 OUTPUTS
# =============================================================================

output "ecommerce_frontend_instance_id" {
  description = "ID of the e-commerce frontend instance"
  value       = var.create_ecommerce_server ? aws_instance.ecommerce_frontend[0].id : null
}

output "ecommerce_frontend_public_ip" {
  description = "Public IP address of the e-commerce frontend instance"
  value       = var.create_ecommerce_server && var.ecommerce_subnet_type == "public" ? (
    length(aws_eip.ecommerce_frontend) > 0 ? aws_eip.ecommerce_frontend[0].public_ip : aws_instance.ecommerce_frontend[0].public_ip
  ) : null
}

output "ecommerce_frontend_private_ip" {
  description = "Private IP address of the e-commerce frontend instance"
  value       = var.create_ecommerce_server ? aws_instance.ecommerce_frontend[0].private_ip : null
}

output "ecommerce_frontend_public_dns" {
  description = "Public DNS name of the e-commerce frontend instance"
  value       = var.create_ecommerce_server && var.ecommerce_subnet_type == "public" ? aws_instance.ecommerce_frontend[0].public_dns : null
}

output "ecommerce_frontend_security_group_id" {
  description = "ID of the e-commerce frontend security group"
  value       = var.create_ecommerce_server ? aws_security_group.ecommerce_frontend[0].id : null
}

output "ecommerce_frontend_key_name" {
  description = "Key pair name used for the e-commerce frontend instance"
  value       = var.create_ecommerce_server ? aws_instance.ecommerce_frontend[0].key_name : null
}

output "ecommerce_frontend_availability_zone" {
  description = "Availability zone of the e-commerce frontend instance"
  value       = var.create_ecommerce_server ? aws_instance.ecommerce_frontend[0].availability_zone : null
}

output "ecommerce_frontend_subnet_id" {
  description = "Subnet ID where the e-commerce frontend instance is deployed"
  value       = var.create_ecommerce_server ? aws_instance.ecommerce_frontend[0].subnet_id : null
}

# Connection Information
output "ecommerce_frontend_ssh_connection" {
  description = "SSH connection command for the e-commerce frontend server"
  value = var.create_ecommerce_server && var.ecommerce_subnet_type == "public" ? format(
    "ssh -i ~/.ssh/%s.pem ubuntu@%s",
    var.key_pair_name,
    length(aws_eip.ecommerce_frontend) > 0 ? aws_eip.ecommerce_frontend[0].public_ip : aws_instance.ecommerce_frontend[0].public_ip
  ) : null
}

# URLs for accessing the frontend
output "ecommerce_frontend_urls" {
  description = "URLs to access the e-commerce frontend application"
  value = var.create_ecommerce_server && var.ecommerce_subnet_type == "public" ? {
    http_url = format("http://%s", 
      length(aws_eip.ecommerce_frontend) > 0 ? aws_eip.ecommerce_frontend[0].public_ip : aws_instance.ecommerce_frontend[0].public_ip
    )
    https_url = format("https://%s", 
      length(aws_eip.ecommerce_frontend) > 0 ? aws_eip.ecommerce_frontend[0].public_ip : aws_instance.ecommerce_frontend[0].public_ip
    )
    react_dev_url = format("http://%s:3000", 
      length(aws_eip.ecommerce_frontend) > 0 ? aws_eip.ecommerce_frontend[0].public_ip : aws_instance.ecommerce_frontend[0].public_ip
    )
    nextjs_url = format("http://%s:3001", 
      length(aws_eip.ecommerce_frontend) > 0 ? aws_eip.ecommerce_frontend[0].public_ip : aws_instance.ecommerce_frontend[0].public_ip
    )
  } : null
}
