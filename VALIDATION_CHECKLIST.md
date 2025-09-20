# ✅ Pre-Commit Validation Checklist

Before pushing your updates to GitHub, please verify:

## 🔧 **Code Quality Checks**

- [ ] **Bash Syntax**: `bash -n user-data.sh` passes without errors
- [ ] **Template Variables**: All `${variable_name}` references are properly defined in `ec2.tf`
- [ ] **Bash Escaping**: All bash variables use `$$` syntax (e.g., `$$(whoami)`)
- [ ] **File Permissions**: `chmod +x test-user-data.sh` if needed

## 🧪 **Testing**

- [ ] **Run Test Script**: `./test-user-data.sh` passes all checks
- [ ] **Terraform Validation**: 
  ```bash
  terraform fmt
  terraform validate
  terraform plan
  ```
- [ ] **Template Rendering**: No syntax errors when Terraform processes templates

## 📋 **File Updates**

- [ ] **user-data.sh**: Updated with fixed syntax and error handling
- [ ] **ec2.tf**: Properly passes template variables to user-data.sh
- [ ] **README.md**: Includes troubleshooting and user-data documentation
- [ ] **test-user-data.sh**: Added for future validation (optional)
- [ ] **.gitignore**: Still protecting sensitive files

## 🔒 **Security Checks**

- [ ] **No Secrets**: No passwords, keys, or sensitive data in any files
- [ ] **terraform.tfvars**: Excluded by .gitignore (never commit this)
- [ ] **SSH Keys**: No .pem or .key files in repository

## 📝 **Documentation**

- [ ] **README.md**: Updated with new features and troubleshooting
- [ ] **Commit Message**: Clear description of fixes and improvements
- [ ] **Version Control**: All changes properly tracked

## 🚀 **Deployment Ready**

- [ ] **Manual Testing**: Successfully tested manual installation on current instance
- [ ] **Template Variables**: Verified all variables are passed correctly
- [ ] **Error Handling**: Script includes proper logging and error checking
- [ ] **Recovery Plan**: Manual installation script available as backup

## 📊 **Final Verification Commands**

```bash
# Check all files are ready
git status

# Validate Terraform configuration
terraform fmt
terraform validate

# Test user-data script
./test-user-data.sh

# Review changes before commit
git diff

# Stage changes
git add .

# Commit with descriptive message
git commit -m "fix: resolve user-data script execution issues and improve reliability"

# Push to GitHub
git push origin main
```

## 🎯 **Success Criteria**

After deployment with the fixed user-data script, the following should work on a fresh EC2 instance:

```bash
# All tools should be installed
docker --version
terraform version
kubectl version --client
node --version
aws --version
helm version

# User should see custom welcome message
cat /etc/motd

# Logs should show successful completion
sudo tail /var/log/user-data.log
```

---

**✅ Check each item above before proceeding with your Git commit and push!**
