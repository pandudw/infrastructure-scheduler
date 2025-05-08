# ----------------------------------------------------------------------
# FUNCTION
# ----------------------------------------------------------------------
variable "function_name" {
  description = "A unique name for your Lambda Function"
  type        = string
  default     = "eks-asg-scheduler"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 500
}

variable "handler" {
  description = "Lambda Function entrypoint in your code"
  type        = string
  default     = "main.lambda_handler"
}

variable "runtime" {
  description = "Lambda Function runtime"
  type        = string
  default     = "python3.10"
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
  default = "test"
}


# ----------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------
variable "role_name" {
  description = "Name of IAM role to use for Lambda Function"
  type        = string
  default     = "EKSNodeSchedulerRole"
}

# ----------------------------------------------------------------------
# POLICY
# ---------------------------------------------------------------------
variable "policy_name" {
  description = "IAM policy name. It override the default value, which is the same as role_name"
  type        = string
  default     = "EKSNodeLambdaScheduler"
}

# ----------------------------------------------------------------------
# EVENTBRIDGE
# ---------------------------------------------------------------------
variable "start_schedule_cron" {
  description = "Cron expression for starting ASG (UTC)"
  type        = string
  default     = "cron(0 1 * * ? *)"
}

variable "stop_schedule_cron" {
  description = "Cron expression for stopping ASG (UTC)"
  type        = string
  default     = "cron(0 12 * * ? *)" 
}

variable "start_schedule_name" {
  description = "CloudWatch Event Rule name for starting ASG"
  type        = string
  default     = "asg-start-schedule"
}

variable "stop_schedule_name" {
  description = "CloudWatch Event Rule name for stopping ASG"
  type        = string
  default     = "asg-stop-schedule"
}

# ----------------------------------------------------------------------
# ARTIFACTS
# ---------------------------------------------------------------------
variable "local_existing_package" {
  description = "The absolute path to an existing zip-file to use"
  type        = string
  default     = "main.zip"
}

# ----------------------------------------------------------------------
# GENERAL
# ---------------------------------------------------------------------
variable "region" {
  default = "ap-southeast-3"
}

variable "project_tag" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default = {
    Project = "ASG-Scheduler"
    Environment = "DEV"
    ManagedBy = "Terraform"
  }
}