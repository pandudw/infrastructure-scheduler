output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.asg_scheduler.lambda_function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = module.asg_scheduler.lambda_function_arn
}

output "lambda_role_name" {
  description = "The name of the IAM role attached to Lambda function"
  value       = module.asg_scheduler.lambda_role_name
}

output "lambda_policy_arn" {
  description = "The ARN of the ASG Control IAM Policy"
  value       =  aws_iam_policy.lambda_policy.arn
}

output "start_schedule_rule_name" {
  description = "The name of the CloudWatch Event rule for starting ASG"
  value       = aws_cloudwatch_event_rule.start_schedule.name
}

output "stop_schedule_rule_name" {
  description = "The name of the CloudWatch Event rule for stopping ASG"
  value       = aws_cloudwatch_event_rule.stop_schedule.name
}

output "start_schedule_rule_arn" {
  description = "The ARN of the CloudWatch Event rule for starting ASG"
  value       = aws_cloudwatch_event_rule.start_schedule.arn
}

output "stop_schedule_rule_arn" {
  description = "The ARN of the CloudWatch Event rule for stopping ASG"
  value       = aws_cloudwatch_event_rule.stop_schedule.arn
}

output "start_lambda_permission_id" {
  description = "The ID of the permission allowing EventBridge to invoke the Lambda function for start"
  value       = aws_lambda_permission.allow_eventbridge_start.statement_id
}

output "stop_lambda_permission_id" {
  description = "The ID of the permission allowing EventBridge to invoke the Lambda function for stop"
  value       = aws_lambda_permission.allow_eventbridge_stop.statement_id
}
