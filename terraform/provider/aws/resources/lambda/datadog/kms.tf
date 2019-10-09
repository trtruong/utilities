resource "aws_kms_key" "cloudops-generic" {
  description             = "CloudOps KMS for ${terraform.workspace}"
  deletion_window_in_days = 7
  is_enabled  = true
  policy                  = "${file("files/kms_policy.json.tpl")}"

  tags = "${merge(
    module.constants_global.tags_default_cloud-ops,
    map(
      "fp-environment", var.env,
      "STAGE", substr(var.env, 0,1)
    ),
  )}"
}

resource "aws_kms_alias" "datadog_api_alias" {
  name          = "alias/cloudops-generic-${terraform.workspace}"
  target_key_id = "${aws_kms_key.cloudops-generic.key_id}"
}

data "aws_kms_ciphertext" "dd_api_encrypted" {
  key_id = "${aws_kms_key.cloudops-generic.key_id}"

  plaintext = "${var.dd_api_key}"
}

variable "dd_api_key" {
  type = "string"
}
