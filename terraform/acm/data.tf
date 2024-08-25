data "aws_route53_zone" "selected" {
  name         = local.workspace["domain_name"]
  private_zone = false
}