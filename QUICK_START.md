# Quick Start: AWS Frontend Infrastructure

Set up the Terraform configuration for AWS networking and an optional Ubuntu EC2 frontend host. The host bootstrap installs development tools; this repository does not include application source code.

## Prerequisites

- Terraform 1.5 or newer, as required by [versions.tf](versions.tf).
- An authenticated AWS CLI session for the target account.
- An existing EC2 key pair in the selected AWS Region.
- A region-appropriate Ubuntu AMI compatible with the configured instance type.

## 1. Clone and configure

```bash
git clone https://github.com/Tuhinzman/terraform-ecommerce-infrastructure.git
cd terraform-ecommerce-infrastructure
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` before continuing:

| Setting | What to review |
| --- | --- |
| `aws_account_id` | Replace the original lab account ID with your target account ID. |
| `aws_region` | Select the AWS Region for this deployment. |
| `key_pair_name` | Use an EC2 key pair that exists in that Region. |
| `ecommerce_ami_id` | Select a suitable Ubuntu AMI in that Region. |
| `allowed_ssh_cidrs` | Replace the example's open SSH rule with the networks that need access. |
| `project_name`, `environment` | Choose the resource naming and environment values. |
| `ecommerce_instance_type`, `ecommerce_subnet_type` | Review the host size and public/private subnet choice. |

Review the NAT gateway and other optional settings in [terraform.tfvars.example](terraform.tfvars.example). The installer downloads packages, so a host in a private subnet needs a working outbound path.

## 2. Check the local files

```bash
terraform fmt -check
bash -n user-data.sh
bash -n scripts/full-install.sh
```

These commands check formatting and shell syntax. They do not run the installer, verify Terraform template rendering or prove that an EC2 instance boots successfully.

The bootstrap path is:

- [ec2.tf](ec2.tf) supplies template inputs to [user-data.sh](user-data.sh).
- `user-data.sh` downloads and runs [scripts/full-install.sh](scripts/full-install.sh).
- The installer changes packages, services and the Ubuntu user's environment. It is not a test script.

## 3. Review and deploy

```bash
terraform init
terraform validate
terraform plan
```

Review the plan, target account and expected costs before applying:

```bash
terraform apply
```

## 4. Inspect outputs and verify the host

When `create_ecommerce_server = true`:

```bash
terraform output ecommerce_frontend_instance_id
terraform output ecommerce_frontend_public_ip
terraform output ecommerce_frontend_ssh_connection
terraform output ecommerce_frontend_urls
```

Use the SSH connection output with the matching private key and network access. On the Ubuntu host, inspect the bootstrap log and verify the tools required for your workload:

```bash
sudo tail -n 100 /var/log/user-data.log
docker --version
terraform version
kubectl version --client
node --version
aws --version
helm version
```

Confirm installation from the log and command results. The completion marker alone is not proof that every installation step succeeded.

Deploy your application separately using its own setup instructions. Output URLs describe addresses and ports; they do not mean an application or HTTPS endpoint is already configured.

## Cleanup

When you intend to remove this deployment, review the destroy plan before confirming:

```bash
terraform plan -destroy
terraform destroy
```

For troubleshooting and configuration details, see [README.md](README.md). Use [VALIDATION_CHECKLIST.md](VALIDATION_CHECKLIST.md) to keep static checks separate from deployment verification.
