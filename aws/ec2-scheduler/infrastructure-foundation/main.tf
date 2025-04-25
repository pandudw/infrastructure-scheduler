terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-3"
  profile = "devops-aws"
}

locals {
  lambda_function_name    = var.function_name
  lambda_timeout          = var.timeout
  lambda_role_name        = var.role_name
  lambda_policy_name      = var.policy_name
  lambda_handler          = var.handler
  lambda_runtime          = var.runtime
  lambda_package          = var.local_existing_package

  start_eventbridge_name  = var.start_schedule_name
  stop_evenbridge_name    = var.stop_schedule_name
  start_eventbridge_cron  = var.start_schedule_cron
  stop_eventbridge_cron   = var.stop_schedule_cron
}

resource "aws_iam_policy" "ec2_control" {
  name   = "EC2ControlPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ {
      Effect   = "Allow"
      Action   = ["ec2:StartInstances", "ec2:StopInstances"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_ec2_policy" {
  name       = "attach_ec2_control"
  roles      = [module.ec2_scheduler.lambda_role_name]
  policy_arn = aws_iam_policy.ec2_control.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = module.ec2_scheduler.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

module "ec2_scheduler" {
  source = "terraform-aws-modules/lambda/aws"
  
  function_name          = local.lambda_function_name
  role_name              = local.lambda_role_name
  policy_name            = local.lambda_policy_name
  handler                = local.lambda_handler
  runtime                = local.lambda_runtime
  timeout                = local.lambda_timeout
  local_existing_package = local.lambda_package 
  create_package         = false
  
  environment_variables = {
    INSTANCE_IDS = var.instance_ids
  }
}

resource "aws_cloudwatch_event_rule" "start_schedule" {
  name                = local.start_eventbridge_name
  schedule_expression = local.start_eventbridge_cron
}

resource "aws_cloudwatch_event_rule" "stop_schedule" {
  name                = local.stop_evenbridge_name
  schedule_expression = local.stop_eventbridge_cron
}

resource "aws_cloudwatch_event_target" "start_lambda" {
  rule = aws_cloudwatch_event_rule.start_schedule.name
  target_id = "StartEC2"
  arn = module.ec2_scheduler.lambda_function_arn
  input = jsonencode({ "ACTION": "start" })
}

resource "aws_cloudwatch_event_target" "stop_lambda" {
  rule = aws_cloudwatch_event_rule.stop_schedule.name
  target_id = "StopEC2"
  arn = module.ec2_scheduler.lambda_function_arn
  input = jsonencode({ "ACTION": "stop" })
}

resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowExecutionFromEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = module.ec2_scheduler.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_schedule.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowExecutionFromEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = module.ec2_scheduler.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_schedule.arn
}
