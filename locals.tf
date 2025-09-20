# =============================================================================
# LOCAL VALUES
# =============================================================================
locals {
  # Common tags applied to all resources
  common_tags = {
    Project     = var.project_display_name
    Environment = title(var.environment)
    ManagedBy   = "terraform"
    CreatedBy   = "devops-team"
    AccountID   = var.aws_account_id
    Region      = var.aws_region
  }

  # Resource naming convention (lowercase)
  name_prefix = "${var.project_name}-${var.environment}"

  # Get AZs dynamically or use provided ones
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 3)

  # Calculate the number of AZs to use
  az_count = length(local.availability_zones)

  # Subnet CIDR calculations
  public_subnet_cidrs   = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 1)]
  private_subnet_cidrs  = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 11)]
  database_subnet_cidrs = [for i in range(local.az_count) : cidrsubnet(var.vpc_cidr, 8, i + 21)]

  # Account validation
  is_correct_account = data.aws_caller_identity.current.account_id == var.aws_account_id

  # Environment-specific configurations
  environment_config = {
    dev = {
      instance_type = "t3.micro"
      min_size      = 1
      max_size      = 3
      desired_size  = 1
    }
    staging = {
      instance_type = "t3.small"
      min_size      = 1
      max_size      = 5
      desired_size  = 2
    }
    prod = {
      instance_type = "t3.medium"
      min_size      = 2
      max_size      = 10
      desired_size  = 3
    }
  }

  # Get current environment config
  current_env_config = local.environment_config[var.environment]
}
