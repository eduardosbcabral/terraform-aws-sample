locals {
  config        = yamldecode(file("./environments/${terraform.workspace}.yaml"))
  global_config = local.config.global
  databases     = local.config.databases

  default_tags = {
    env           = local.global_config.env
    repository    = local.global_config.repository
    documentation = local.global_config.documentation
  }
}