locals {
  workspace = yamldecode(file("./environments/${terraform.workspace}.yaml"))

  region = local.workspace["region"]

  default_tags = {
    managed_by    = local.workspace["managed_by"]
    env           = local.workspace["env"]
    repository    = local.workspace["repository"]
    service       = "${local.workspace["name"]}-${local.workspace["env"]}"
    documentation = local.workspace["documentation"]
  }
}