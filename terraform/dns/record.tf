resource "aws_route53_zone" "dev_sample" {
  provider = aws.dev

  name = local.global_config.dns_name
}

resource "aws_route53_record" "ns_for_dev_sample" {
  provider = aws.root

  zone_id = local.global_config.root_hosted_zone_id
  name    = local.global_config.dns_name
  type    = "NS"
  ttl     = "172800"

  records = aws_route53_zone.dev_sample.name_servers
}

resource "aws_route53_record" "api_dev" {
  provider = aws.dev

  for_each = toset([local.dns.api.domain_name]) 

  zone_id = aws_route53_zone.dev_sample.zone_id
  name    = "${each.value}.${local.global_config.dns_name}"
  type    = "A"

  alias {
    name                   = local.global_config.alb_name
    zone_id                = local.global_config.dev_hosted_zone_id
    evaluate_target_health = true
  }
}