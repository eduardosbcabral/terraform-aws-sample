provider "aws" {
  region = local.global_config.region
  default_tags {
    tags = local.default_tags
  }
}