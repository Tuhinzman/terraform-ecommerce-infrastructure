# =============================================================================
# EC2 RESOURCES - E-COMMERCE FRONTEND SERVER
# =============================================================================

# Security Group for E-commerce Frontend Server
resource "aws_security_group" "ecommerce_frontend" {
  count = var.create_ecommerce_server ? 1 : 0

  name_prefix = "${local.name_prefix}-ecommerce-frontend-"
  description = "Security group for e-commerce frontend server"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # HTTP access for frontend application
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access for frontend application
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom frontend port (React dev server)
  ingress {
    description = "React dev server"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Next.js default port
  ingress {
    description = "Next.js server"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker container ports (8000-8099)
  ingress {
    description = "Docker container ports"
    from_port   = 8000
    to_port     = 8099
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nginx default port
  ingress {
    description = "Nginx"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecommerce-frontend-sg"
    Type = "security-group"
    Tier = "frontend"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# User Data Script for Software Installation
locals {
  user_data_script = var.create_ecommerce_server ? base64encode(templatefile("${path.module}/user-data.sh", {
    project_name        = var.project_name
    environment         = var.environment
    terraform_version   = "1.6.6"
  })) : ""
}

# E-commerce Frontend Server
resource "aws_instance" "ecommerce_frontend" {
  count = var.create_ecommerce_server ? 1 : 0

  ami                     = var.ecommerce_ami_id
  instance_type           = var.ecommerce_instance_type
  key_name                = var.key_pair_name
  subnet_id               = var.ecommerce_subnet_type == "public" ? aws_subnet.public[0].id : aws_subnet.private[0].id
  vpc_security_group_ids  = [aws_security_group.ecommerce_frontend[0].id]
  user_data               = local.user_data_script
  monitoring              = var.enable_detailed_monitoring

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.ecommerce_volume_size
    delete_on_termination = true
    encrypted             = true

    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-ecommerce-frontend-root-volume"
      Type = "ebs-volume"
    })
  }

  # Instance metadata options (security best practice)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-ecommerce-frontend"
    Type        = "ec2-instance"
    Tier        = "frontend"
    Application = "ecommerce"
    Backup      = "true"
  })

  # Prevent accidental termination in production
  disable_api_termination = var.environment == "prod" ? true : false

  lifecycle {
    create_before_destroy = false
    ignore_changes = [
      user_data, # Ignore changes to user data after initial creation
    ]
  }
}

# Elastic IP for E-commerce Frontend (optional for public subnet)
resource "aws_eip" "ecommerce_frontend" {
  count = var.create_ecommerce_server && var.ecommerce_subnet_type == "public" ? 1 : 0

  instance = aws_instance.ecommerce_frontend[0].id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecommerce-frontend-eip"
    Type = "elastic-ip"
    Tier = "frontend"
  })

  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# CLOUDWATCH ALARMS FOR MONITORING
# =============================================================================

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "ecommerce_cpu_utilization" {
  count = var.create_ecommerce_server ? 1 : 0

  alarm_name          = "${local.name_prefix}-ecommerce-frontend-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"

  dimensions = {
    InstanceId = aws_instance.ecommerce_frontend[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecommerce-cpu-alarm"
    Type = "cloudwatch-alarm"
  })
}

# Status Check Failed Alarm
resource "aws_cloudwatch_metric_alarm" "ecommerce_status_check" {
  count = var.create_ecommerce_server ? 1 : 0

  alarm_name          = "${local.name_prefix}-ecommerce-frontend-status-check"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors ec2 status check"

  dimensions = {
    InstanceId = aws_instance.ecommerce_frontend[0].id
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecommerce-status-alarm"
    Type = "cloudwatch-alarm"
  })
}
