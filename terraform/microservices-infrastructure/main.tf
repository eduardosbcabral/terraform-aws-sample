resource "aws_ecs_task_definition" "task" {
  for_each                 = local.microservices
  family                   = "${each.value.service_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution_role[each.key].arn
  cpu                      = "256" 
  memory                   = "512" 
  # task_role_arn = "role_arn_for_services_todo"
  container_definitions = templatefile("${path.module}/container-definitions/${each.value.service_name}/${local.global_config.env}.json", {
    service_name = each.value.service_name,
    port         = each.value.port != "" ? each.value.port : 8080,
    region       = local.global_config.region
    env          = local.global_config.env
    account_id   = local.global_config.account_id
  })
}

resource "aws_iam_role" "execution_role" {
  for_each           = local.microservices
  name               = "${each.value.service_name}-execution-role"
  assume_role_policy = file("${path.module}/container-definitions/${each.value.service_name}/default_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy_ecs" {
  for_each   = local.microservices
  role       = aws_iam_role.execution_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy_cloudwatch" {
  for_each   = local.microservices
  role       = aws_iam_role.execution_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_policy" "task_ecs_permissions" {
  for_each = local.microservices
  name     = "${each.value.service_name}-permissions-role"
  policy   = templatefile("${path.module}/container-definitions/${each.value.service_name}/ecs_role_policy.json", {
    region     = local.global_config.region,
    account_id = local.global_config.account_id
  })
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy_permissions" {
  for_each   = local.microservices
  role       = aws_iam_role.execution_role[each.key].name
  policy_arn = aws_iam_policy.task_ecs_permissions[each.key].arn
}

resource "aws_ecs_service" "service" {
  for_each        = local.microservices
  name            = each.value.service_name
  cluster         = "${local.global_config.cluster_name}-${local.global_config.env}"
  task_definition = aws_ecs_task_definition.task[each.key].arn
  launch_type     = "FARGATE"

  desired_count = 2

  network_configuration {
    subnets          = local.global_config.subnet_ids
    security_groups  = [aws_security_group.ecs_service[each.key].id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this[each.key].arn
    container_name   = "${each.value.service_name}-container"
    container_port   = each.value.port != "" ? each.value.port : 8080
  }
  lifecycle {
    ignore_changes = [task_definition]
  }
}

resource "aws_lb_target_group" "this" {
  for_each    = local.microservices
  name        = each.value.service_name
  port        = each.value.port != "" ? each.value.port : 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.global_config.vpc_id
  health_check {
    enabled  = true
    path     = each.value.health_check_path != "" ? each.value.health_check_path : "/"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_listener_rule" "example" {
  for_each     = local.microservices
  listener_arn = data.aws_ssm_parameter.http_listener_arn.value

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    path_pattern {
      values = each.value.path
    }
  }
}

resource "aws_security_group" "ecs_service" {
  for_each    = local.microservices
  name        = "${each.value.service_name}-ecs-service"
  description = "Allow traffic to ECS service"
  vpc_id      = local.global_config.vpc_id

  ingress {
    from_port   = each.value.port != "" ? each.value.port : 8080
    to_port     = each.value.port != "" ? each.value.port : 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "this" {
  for_each = local.microservices
  name     = each.value.service_name
}

resource "aws_cloudwatch_log_group" "this" {
  for_each     = local.microservices
  name = "/ecs/${each.value.service_name}-${local.global_config.env}-logs"
}