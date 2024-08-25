module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.1"

  name = "${local.global_config.name}-${local.global_config.env}"
  cidr = local.global_config.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.global_config.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.global_config.vpc_cidr, 8, k + 4)]

  private_subnet_names = local.global_config.private_subnet_names
  public_subnet_names  = local.global_config.public_subnet_names

  create_database_subnet_group  = true
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_nat_gateway  = true
  single_nat_gateway  = true
  enable_vpn_gateway  = false
  enable_dhcp_options = true

  tags = local.default_tags
}