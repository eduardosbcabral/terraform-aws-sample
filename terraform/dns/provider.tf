provider "aws" {
  alias  = "root"
  region = local.global_config.region
  assume_role {
    role_arn     = local.global_config.role_arn
    session_name = local.global_config.session_name
  }
  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "dev"
  region = local.global_config.region
  default_tags {
    tags = local.default_tags
  }
}