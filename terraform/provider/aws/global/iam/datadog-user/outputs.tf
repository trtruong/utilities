output "datadog_lambda_role_arn" {
  value = aws_iam_role.datadog-lambda.arn
}

output "datadog_integration_role_arn" {
  value = aws_iam_role.datadog_aws_integration.arn
}

