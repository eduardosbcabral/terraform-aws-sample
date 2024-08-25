module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "v5.10.0"

  cluster_name = "${local.global_config.name}-${local.global_config.env}"

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
  }

  tags = local.default_tags
}