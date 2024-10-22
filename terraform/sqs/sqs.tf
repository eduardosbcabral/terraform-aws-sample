resource "aws_sqs_queue" "terraform_queue" {
  for_each                  = local.queues
  name                      = "${each.value.name}-${local.global_config.env}"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400 // 1 dia
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue" "terraform_queue_deadletter" {
  for_each                  = local.queues
  name                      = "${each.value.dead_letter}-${local.global_config.env}"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 1209600 // 14 dias
  receive_wait_time_seconds = 10
}