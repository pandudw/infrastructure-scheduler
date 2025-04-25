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
  profile = "jawara-poc"
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
  
  function_name          = "ec2-scheduler"
  role_name              = "EC2SchedulerRole"
  policy_name            = "LambdaSchedulerLogs"
  handler                = "main.lambda_handler"
  runtime                = "python3.10"
  timeout                = 300
  local_existing_package = "main.zip" 
  create_package         = false
  
  environment_variables = {
    INSTANCE_IDS = var.instance_ids
  }
}

resource "aws_cloudwatch_event_rule" "start_schedule" {
  name                = "ec2-start-schedule"
  schedule_expression = "cron(0 1 * * ? *)"  
}

resource "aws_cloudwatch_event_rule" "stop_schedule" {
  name                = "ec2-stop-schedule"
  schedule_expression = "cron(0 12 * * ? *)" 
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
