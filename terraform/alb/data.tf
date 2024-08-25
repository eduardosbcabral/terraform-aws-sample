# TODO: ENABLE WHEN DNS IS NEEDED
# data "aws_acm_certificate" "my_acm" {
#   domain      = local.global_config.domain_name
#   statuses    = ["ISSUED"]
#   most_recent = true
# }