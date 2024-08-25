locals {
  workspace     = yamldecode(file("./environments/${terraform.workspace}.yaml"))
  global_config = local.workspace.global

  region = local.global_config.region

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  default_tags = {
    managed_by    = local.global_config.tags.managed_by
    env           = local.global_config.env
    repository    = local.global_config.tags.repository
    service       = "${local.global_config.name}-${local.global_config.env}"
    documentation = local.global_config.tags.documentation
  }
} 