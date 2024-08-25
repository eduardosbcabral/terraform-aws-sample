locals {
  config        = yamldecode(file("./environments/${terraform.workspace}.yaml"))
  global_config = local.config.global
  dns           = local.config.dns

  default_tags = {
    env           = local.global_config.env
    repository    = local.global_config.tags.repository
    managed_by    = local.global_config.tags.managed_by
    service       = local.global_config.tags.service
    documentation = local.global_config.tags.documentation
  }
}