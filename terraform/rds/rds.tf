resource "aws_security_group" "rds_sg" {
  for_each    = local.databases
  name        = "${each.value.name}-sg"
  description = "Security group for RDS allowing access from anywhere"
  vpc_id      = local.global_config.vpc_id

  ingress {
    from_port   = each.value.port
    to_port     = each.value.port
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

module "db" {
  for_each                    = local.databases
  source                      = "terraform-aws-modules/rds/aws"
  identifier                  = "${each.value.name}-${local.global_config.env}"
  engine                      = each.value.engine
  engine_version              = each.value.version
  instance_class              = each.value.instance
  allocated_storage           = each.value.storage
  db_name                     = "${each.value.name}${local.global_config.env}"
  username                    = each.value.username
  port                        = each.value.port
  manage_master_user_password = true
  skip_final_snapshot         = true
  publicly_accessible         = true
  vpc_security_group_ids      = [aws_security_group.rds_sg[each.key].id]
  create_db_parameter_group   = false
  parameter_group_name        = each.value.parameter_group_name
  create_db_subnet_group      = true
  subnet_ids                  = local.global_config.subnet_ids
}