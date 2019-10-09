terraform {
  backend "s3" {
    encrypt              = "true"
  }
}

data "terraform_remote_state" "datadog-iam" {
  backend = "s3"
  config = {
    bucket = var.bucket-map[var.env]
    region = "us-east-2"
    key    = "aws/global/iam/datadog/terraform.tfstate"
  }
}
