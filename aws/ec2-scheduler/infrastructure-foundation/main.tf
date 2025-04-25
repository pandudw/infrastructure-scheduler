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

resource "aws_iam_role" "lambda_role" {
  name = "ec2-scheduler-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ec2_control" {
  name   = "EC2ControlPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ec2:StartInstances", "ec2:StopInstances"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_ec2_policy" {
  name       = "attach_ec2_control"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.ec2_control.arn
}

resource "aws_lambda_function" "ec2_scheduler" {
  function_name = "ec2-scheduler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.10"
  filename      = "main.zip"
  source_code_hash = filebase64sha256("main.zip")
  timeout = 300

  environment {
    variables = {
      INSTANCE_IDS = var.instance_ids
    }
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
  arn = aws_lambda_function.ec2_scheduler.arn
  input = jsonencode({ "ACTION": "start" })
}

resource "aws_cloudwatch_event_target" "stop_lambda" {
  rule = aws_cloudwatch_event_rule.stop_schedule.name
  target_id = "StopEC2"
  arn = aws_lambda_function.ec2_scheduler.arn
  input = jsonencode({ "ACTION": "stop" })
}

resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowExecutionFromEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_schedule.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowExecutionFromEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_schedule.arn
}
