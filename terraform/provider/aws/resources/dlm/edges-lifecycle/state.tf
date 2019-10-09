terraform {
  required_version = ">= 0.12"
  backend "s3" {
    encrypt              = "true"
    workspace_key_prefix = "regions"
  }
}

data "terraform_remote_state" "dlm_iam_role" {
  backend = "s3"

  config = {
    bucket = var.bucket_name[var.env]
    region = "us-east-2"
    key    = "aws/global/iam/dlm/terraform.tfstate"
  }
}
