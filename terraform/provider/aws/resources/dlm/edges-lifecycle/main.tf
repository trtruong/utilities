provider "aws" {
  region = terraform.workspace
}

module "aws-dlm" {
  source = "git::https://github.cicd.cloud.fpdev.io/CLDOPS/aws-dlm.git"
  copy_tags = true
  dlm_policy_description = join(" ", [terraform.workspace, "Edge Snapshot retention"])
  resource_type = ["INSTANCE"]
  schedule_name = join("-", [terraform.workspace, "EdgeSnaphots2WeeksRention"])
  lifecycle_role_arn = data.terraform_remote_state.dlm_iam_role.outputs.dlm_role_arn
  lifecycle_policy_name = join("-", [terraform.workspace, "edge-dlm-permissions"])
  interval = 24
  retention = 14
  times = ["23:45"]
  target_tags = {
    "Name" = "vm-${var.regions[terraform.workspace]}-cpt-s-edge-ngfw670"
  }
  tags_to_add = {
    "SnapshotCreator" = "DLM"
    "Name" = join("-", [terraform.workspace, "edge-nfgw-snapshot"])
  }
}
