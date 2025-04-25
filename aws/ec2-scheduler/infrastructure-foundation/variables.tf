# ----------------------------------------------------------------------
# FUNCTION
# ----------------------------------------------------------------------
variable "function_name" {
  description = "A unique name for your Lambda Function"
  type        = string
  default     = "ec2-scheduler"
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 300
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

# ----------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------
variable "role_name" {
  description = "Name of IAM role to use for Lambda Function"
  type        = string
  default     = "EC2SchedulerRole"
}

# ----------------------------------------------------------------------
# POLICY
# ---------------------------------------------------------------------
variable "policy_name" {
  description = "IAM policy name. It override the default value, which is the same as role_name"
  type        = string
  default     = "LambdaSchedulerLogs"
}

# ----------------------------------------------------------------------
# EVENTBRIDGE
# ---------------------------------------------------------------------
variable "start_schedule_cron" {
  description = "Cron expression for starting EC2 instances (UTC)"
  type        = string
  default     = "cron(0 1 * * ? *)"
}

variable "stop_schedule_cron" {
  description = "Cron expression for stopping EC2 instances (UTC)"
  type        = string
  default     = "cron(0 12 * * ? *)" 
}

variable "start_schedule_name" {
  description = "CloudWatch Event Rule name for starting EC2"
  type        = string
  default     = "ec2-start-schedule"
}

variable "stop_schedule_name" {
  description = "CloudWatch Event Rule name for stopping EC2"
  type        = string
  default     = "ec2-stop-schedule"
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

variable "instance_ids" {
  description = "Comma separated EC2 instance IDs"
  default     = "i-021b6f9d93c3a2f0c"
}