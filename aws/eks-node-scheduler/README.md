# EKS Node Group Scheduler

This module enables scheduled scaling of EKS Managed Node Groups using AWS Lambda and EventBridge, managed via Terraform.

## ✨ Features

- ⏫ Scale up EKS Node Groups at a scheduled time (e.g., 08:00 WIB)
- ⏬ Scale down EKS Node Groups at a scheduled time (e.g., 19:00 WIB)
- 🔐 IAM policies scoped to only required permissions
- 🔁 Reusable and environment-agnostic with Terraform
- 🐍 Custom Python logic for Lambda to update EKS Auto Scaling Groups

## 📦 Architecture

- **Lambda Function**: Executes the logic to scale the node group
- **EventBridge Rules**: Define the schedule for scaling up/down
- **IAM Role**: Grants Lambda permissions to update the Node Group via ASG
- **Terraform Module**: All infrastructure as code


## 🧠 Requirements

- Terraform >= 1.3.2
- AWS Provider >= 5.83
- Python 3.10
- Existing EKS Cluster and Node Group
- IAM permissions to modify Auto Scaling Groups linked to EKS

## 🔧 Configuration

Update `variables.tf` with:
- `function_name`, `role_name`, `handler`, etc.
- EKS-managed Node Group's underlying Auto Scaling Group name
- Start and stop cron expressions

## 🚀 Getting Started
1. Clone this repo
2. Zip your main.py as main.zip:
```bash
zip main.zip main.py
```
3. Deploy with Terraform:
```bash
terraform init
terraform plan
terraform apply
```