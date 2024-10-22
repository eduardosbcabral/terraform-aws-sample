locals {
  workspace     = yamldecode(file("./environments/${terraform.workspace}.yaml"))
  global_config = local.workspace.global
  buckets    = local.workspace.buckets

  default_tags = {
    managed_by    = local.global_config.tags.managed_by
    env           = local.global_config.env
    repository    = local.global_config.tags.repository
    documentation = local.global_config.tags.documentation
  }
}