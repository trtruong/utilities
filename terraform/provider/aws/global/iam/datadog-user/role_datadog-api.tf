#variable "datadog_aws_integration_external_id" {
#  default     = "ec1cb682a79140349905247d959d6e99"
#  description = "<YOUR_DD_EXTERNAL_ID>"
#}

data "aws_iam_policy_document" "datadog_aws_integration_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"

      values = [
        "${datadog_integration_aws.dd-integration.external_id}"
      ]
    }
  }
}


resource "aws_iam_role" "datadog-lambda" {
  name               = "datadog-lambda-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "datadog_aws_integration" {
  name = "DatadogAWSIntegrationPolicy"
  policy = "${file("files/datadog_policy.json.tpl")}"
}

resource "aws_iam_role" "datadog_aws_integration" {
  name = "DatadogAWSIntegrationRole"
  description = "Role for Datadog AWS Integration"
  assume_role_policy = "${data.aws_iam_policy_document.datadog_aws_integration_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "datadog_aws_integration" {
  role = "${aws_iam_role.datadog_aws_integration.name}"
  policy_arn = "${aws_iam_policy.datadog_aws_integration.arn}"
}

resource "aws_iam_role_policy_attachment" "datadog_lambda_integration_perms" {
  role = "${aws_iam_role.datadog-lambda.name}"
  policy_arn = "${aws_iam_policy.datadog_aws_integration.arn}"
}

resource "aws_iam_role_policy_attachment" "datadog-lambda-s3" {
  role = "${aws_iam_role.datadog-lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "datadog-lambda-cloudwatch" {
  role = "${aws_iam_role.datadog-lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
