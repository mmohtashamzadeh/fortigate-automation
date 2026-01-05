# FortiGate Firewall Automation (Terraform + Ansible + Jenkins)

## What it does
- Terraform manages desired-state firewall policies (data-driven rules)
- Ansible handles operational tasks (backup, post-apply checks)
- Jenkins orchestrates CI/CD with approvals and auditability

## How to run locally (example)
cd terraform
terraform init
terraform plan -var "fgt_host=..." -var "fgt_token=..." -var-file ../envs/dev.tfvars

