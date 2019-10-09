terraform {
  required_version = ">= 0.12"
  backend "s3" {
    encrypt        = "true"
    dynamodb_table = "use2-cops-terraform-remote-state"
    region         = "us-east-2"
    key            = "aws/global/iam/dlm/terraform.tfstate"
  }
}
