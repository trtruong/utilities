resource "aws_lambda_function" "datadog_lambda" {
  filename         = "functions/datadog_lambda.zip"
  function_name    = "datadog_lambda"
  role             = "${data.terraform_remote_state.datadog-iam.outputs.datadog_lambda_role_arn}"
  handler          = "lambda_function.lambda_handler"
  timeout          = 120
  memory_size      = 1024
  source_code_hash = "${filebase64sha256("functions/datadog_lambda.zip")}"
  runtime          = "python2.7"
  environment {
    variables = {
      DD_KMS_API_KEY = "${data.aws_kms_ciphertext.dd_api_encrypted.ciphertext_blob}"
    }
  }

  tags = merge(
    module.constants_global.tags_default_cloud-ops,
    {
      "fp-environment" = var.env
      "STAGE"          = substr(var.env, 0, 1)
    },
  )
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.datadog_lambda.function_name}"
  principal     = "logs.amazonaws.com"
}

resource "aws_lambda_permission" "allow_s3_buckets" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.datadog_lambda.function_name}"
  principal     = "s3.amazonaws.com"
}

resource "aws_cloudwatch_log_subscription_filter" "kms_datadog_lambdafunction_logfilter" {
  count           = "${terraform.workspace == "us-east-1" || terraform.workspace == "us-west-1" || terraform.workspace == "us-east-2" ? 1 : 0}"
  name            = "kms_datadog_lambdafunction_logfilter"
  log_group_name  = "kms/cwlg-kms-s"
  filter_pattern  = ""
  destination_arn = "${aws_lambda_function.datadog_lambda.arn}"
}

resource "aws_cloudwatch_log_subscription_filter" "edge-ngfw_datadog_lambdafunction_logfilter" {
  name            = "edge-ngfw_datadog_lambdafunction_logfilter"
  log_group_name  = "/edge/ngfw/monitoring"
  filter_pattern  = ""
  destination_arn = "${aws_lambda_function.datadog_lambda.arn}"
  distribution    = "Random"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = "${terraform.workspace == "us-east-1" ? 1 : 0}"
  bucket = "s3-use1-cpt-s-customer-events"
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.datadog_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
