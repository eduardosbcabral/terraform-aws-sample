data "aws_acm_certificate" "my_acm" {
  for_each = {
    for k, v in local.buckets : k => v
    if v.domain_name != ""
  }

  domain      = each.value.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}