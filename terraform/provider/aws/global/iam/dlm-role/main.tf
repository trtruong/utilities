resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlm_lifecycle_role"
  tags = merge(
    module.constants_global.tags_default_cloud-ops,
    {
      "fp-environment"     = var.env
      "STAGE"              = var.env_short[var.env]
      "fp-cost-centre"     = "221",
      "fp-technical-owner" = "CPT-Colorado@forcepoint.com"
    },
  )

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name = "lifecycle_policy_name"
  role = "${aws_iam_role.dlm_lifecycle_role.id}"

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
           "ec2:CreateSnapshot",
           "ec2:CreateSnapshots",
           "ec2:DeleteSnapshot",
           "ec2:DescribeVolumes",
           "ec2:DescribeInstances",
           "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}
