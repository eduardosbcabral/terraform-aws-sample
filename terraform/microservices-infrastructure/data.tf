# Change it to https when dns is created
data "aws_ssm_parameter" "http_listener_arn" {
  name = "/${local.global_config.alb}/http-listener-arn"
}
# TODO: ENABLE WHEN DNS IS NEEDED
# data "aws_ssm_parameter" "http_listener_arn" {
#   name = "/${local.global_config.alb}/https-listener-arn"
# }