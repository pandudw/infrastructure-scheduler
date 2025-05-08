# Infrastructure Scheduler

This repository contains Terraform configurations and a Python script to automatically schedule start and stop operations for EC2 instances using AWS Lambda, CloudWatch EventBridge, and IAM roles.

## ✨ Features
- ⏰ Automatically starts EC2 instances daily at 08:00 WIB (UTC+7)
- 🛑 Automatically stops EC2 instances daily at 19:00 WIB (UTC+7)
- ⚙️ Fully managed and reproducible using Terraform
- 🐍 Custom Python logic (main.py) for AWS Lambda
- 📦 Serverless architecture — no EC2 for scheduling

## 🧠 Requirements
- Terraform >= 1.3.2
- AWS Provider >= 5.83
- Python 3.10
- AWS credentials with permission to manage EC2, Lambda, IAM, and EventBridge

## 🚀 Getting Started
1. Clone this repo
2. Update variables.tf to set your target EC2 instance IDs and cron schedule if needed
3. Zip your main.py as main.zip:
```bash
zip main.zip main.py
```
4. Deploy with Terraform:
```bash
terraform init
terraform plan
terraform apply
```