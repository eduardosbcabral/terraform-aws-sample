module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = "${local.global_config.alb_name}-public"

  load_balancer_type = local.global_config.load_balancer_type

  vpc_id  = local.global_config.vpc_id
  subnets = local.global_config.subnet_ids

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }



  listeners = {
    ex_http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "ex_ecs"
      }
    }
    # TODO: ENABLE WHEN DNS IS NEEDED
    # ex_https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   certificate_arn = data.aws_acm_certificate.my_acm.arn

    #   forward = {
    #     target_group_key = "ex_ecs_https"
    #   }
    # }
  }

  target_groups = {
    ex_ecs = {
      backend_protocol                  = "HTTP"
      backend_port                      = local.global_config.container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = local.global_config.path
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = local.global_config.create_attachment
    }

  # TODO: ENABLE WHEN DNS IS NEEDED
  #   ex_ecs_https = {
  #     backend_protocol                  = "HTTPS"
  #     backend_port                      = local.global_config.container_port
  #     target_type                       = "ip"
  #     deregistration_delay              = 5
  #     load_balancing_cross_zone_enabled = true

  #     health_check = {
  #       enabled             = true
  #       healthy_threshold   = 5
  #       interval            = 30
  #       matcher             = "200"
  #       path                = local.global_config.path
  #       port                = "traffic-port"
  #       protocol            = "HTTP"
  #       timeout             = 5
  #       unhealthy_threshold = 2
  #     }

  #     # There's nothing to attach here in this definition. Instead,
  #     # ECS will attach the IPs of the tasks to this target group
  #     create_attachment = local.global_config.create_attachment
  #   }
  }
  tags = local.default_tags
}

resource "aws_ssm_parameter" "http_listener_arn" {
  description = "ARN of the HTTP listener"
  name        = "/${local.global_config.alb_name}/http-listener-arn"
  type        = "String"
  value       = module.alb.listeners["ex_http"]["arn"]
}

# TODO: ENABLE WHEN DNS IS NEEDED
# resource "aws_ssm_parameter" "https_listener_arn" {
#   description = "ARN of the HTTPS listener"
#   name        = "/${local.global_config.alb_name}/https-listener-arn"
#   type        = "String"
#   value       = module.alb.listeners["ex_https"]["arn"]
# } 