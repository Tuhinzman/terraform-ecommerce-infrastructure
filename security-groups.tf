# =============================================================================
# SECURITY GROUPS
# =============================================================================

# Application Load Balancer Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${local.name_prefix}-alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # HTTP access from internet
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from internet
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (standard practice for ALB)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
    Type = "security-group"
    Tier = "load-balancer"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Application Servers Security Group
resource "aws_security_group" "application" {
  name_prefix = "${local.name_prefix}-app-"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main.id

  # HTTP from ALB
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # HTTPS from ALB
  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # SSH from bastion (when implemented)
  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Custom application ports (adjust as needed)
  ingress {
    description     = "Custom app port from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Node.js/Express default port
  ingress {
    description     = "Node.js from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Outbound internet access (for updates, external APIs)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-application-sg"
    Type = "security-group"
    Tier = "application"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Database Security Group
resource "aws_security_group" "database" {
  name_prefix = "${local.name_prefix}-db-"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.main.id

  # MySQL/Aurora access from application servers
  ingress {
    description     = "MySQL from application servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  # PostgreSQL access (if needed)
  ingress {
    description     = "PostgreSQL from application servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  # Redis access (if using ElastiCache)
  ingress {
    description     = "Redis from application servers"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  # MongoDB access (if needed)
  ingress {
    description     = "MongoDB from application servers"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  # Database administration from bastion
  ingress {
    description     = "MySQL admin from bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "PostgreSQL admin from bastion"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # No outbound rules - databases typically don't need outbound access

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-database-sg"
    Type = "security-group"
    Tier = "data"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host Security Group (for secure SSH access)
resource "aws_security_group" "bastion" {
  name_prefix = "${local.name_prefix}-bastion-"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  # SSH access from specific IP ranges (customize as needed)
  ingress {
    description = "SSH from office/VPN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # CHANGE THIS to your office/VPN IP ranges
  }

  # Outbound SSH to private subnets
  egress {
    description = "SSH to private subnets"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }

  # Outbound SSH to database subnets (for DB administration)
  egress {
    description = "SSH to database subnets"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.database_subnet_cidrs
  }

  # Database access for administration
  egress {
    description = "MySQL to database subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = local.database_subnet_cidrs
  }

  egress {
    description = "PostgreSQL to database subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.database_subnet_cidrs
  }

  # Outbound for updates
  egress {
    description = "HTTPS for updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "HTTP for updates"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS resolution
  egress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion-sg"
    Type = "security-group"
    Tier = "management"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EFS Security Group (for shared file systems)
resource "aws_security_group" "efs" {
  name_prefix = "${local.name_prefix}-efs-"
  description = "Security group for EFS mount targets"
  vpc_id      = aws_vpc.main.id

  # NFS access from application servers
  ingress {
    description     = "NFS from application servers"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  # NFS access from bastion (for administration)
  ingress {
    description     = "NFS from bastion"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-efs-sg"
    Type = "security-group"
    Tier = "storage"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ElastiCache Security Group
resource "aws_security_group" "elasticache" {
  name_prefix = "${local.name_prefix}-cache-"
  description = "Security group for ElastiCache clusters"
  vpc_id      = aws_vpc.main.id

  # Redis access from application servers
  ingress {
    description     = "Redis from application servers"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  # Memcached access from application servers
  ingress {
    description     = "Memcached from application servers"
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = [aws_security_group.application.id]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-elasticache-sg"
    Type = "security-group"
    Tier = "cache"
  })

  lifecycle {
    create_before_destroy = true
  }
}
