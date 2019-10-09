resource "aws_acm_certificate" "ts-portal" {
  domain_name       = var.domain_name
  validation_method = "EMAIL"

  tags = merge(
    module.constants_global.tags_default_cloud-ops,
    {
      "fp-environment" = var.fp_environment_tag
      "STAGE"          = var.STAGE
      "fp-cost-centre" = "221",
      "fp-technical-owner" = "CPT-Colorado@forcepoint.com"
    },
  )
  lifecycle {
    create_before_destroy = true
  }
}
