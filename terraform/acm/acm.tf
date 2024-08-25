module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = local.workspace["domain_name"]
  zone_id     = data.aws_route53_zone.selected.zone_id

  validation_method = "DNS"

  subject_alternative_names = local.workspace["subject_alternative_names"]

  wait_for_validation = false
}

resource "aws_ssm_parameter" "acm_certificate_arn" {
  name  = "/${terraform.workspace}/acm_certificate_arn"
  type  = "String"
  value = module.acm.acm_certificate_arn
}