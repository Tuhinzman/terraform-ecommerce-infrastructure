# Validation Checklist

Use this checklist when changing the configuration. It is a list of checks to perform, not a record of a successful deployment.

## Local files and syntax

- [ ] Review changes to the Terraform configuration, `user-data.sh` and `scripts/full-install.sh`.
- [ ] Confirm that referenced files and script paths exist.
- [ ] Check the bootstrap download URL and the `project_name`, `environment` and `terraform_version` inputs supplied in `ec2.tf`.
- [ ] Keep credentials, private keys and local `terraform.tfvars` values out of commits.

From the repository root:

```bash
terraform fmt -check
bash -n user-data.sh
bash -n scripts/full-install.sh
```

`bash -n` parses the scripts without executing them. It does not validate rendered Terraform templates, network downloads, package installation or an EC2 boot.

## Terraform configuration

- [ ] Copy [terraform.tfvars.example](terraform.tfvars.example) to `terraform.tfvars` and review the target account, Region, key pair, AMI and SSH CIDRs.
- [ ] Initialize the configuration and validate it before planning a deployment.
- [ ] Review the plan for the intended resources and costs.

```bash
terraform init
terraform validate
terraform plan
```

These commands are deployment-preparation steps. A plan uses the configured AWS credentials and is separate from the local syntax checks above.

## Runtime verification after deployment

- [ ] Inspect `/var/log/user-data.log` on the target Ubuntu host for bootstrap and installation errors.
- [ ] Verify the required tools with the version commands in [QUICK_START.md](QUICK_START.md).
- [ ] Check the application separately after deploying its own source and configuration.
- [ ] Record the commands and results used to verify the deployment; do not treat a completion marker or an unchecked list as evidence of success.

## Documentation review

- [ ] Clone commands use the actual repository URL and directory.
- [ ] Examples match the files and outputs in this repository.
- [ ] Installer commands are described as installation steps, not tests.
- [ ] Setup or runtime claims match the validation actually performed.
