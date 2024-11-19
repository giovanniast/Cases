resource "aws_sqs_queue" "terraform_queue" {
  for_each                   = var.filas-sqs
  name                       = each.value.fifo_queue != null ? "${each.key}.fifo" : each.key
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  delay_seconds              = each.value.delay_seconds
  max_message_size           = each.value.max_message_size
  message_retention_seconds  = each.value.message_retention_seconds
  receive_wait_time_seconds  = each.value.receive_wait_time_seconds
  fifo_queue                 = each.value.fifo_queue
  sqs_managed_sse_enabled    = true
  redrive_policy = each.value.deadletter != null ? jsonencode({
    deadLetterTargetArn = "${aws_sqs_queue.terraform_queue_deadletter[each.value.deadletter].arn}"
    maxReceiveCount     = 5
  }) : null
  tags = var.tag_project
}

resource "aws_sqs_queue" "terraform_queue_deadletter" {
  for_each                   = var.filas-sqs-deadletter
  name                       = each.value.fifo_queue != null ? "${each.key}.fifo" : each.key
  message_retention_seconds  = each.value.message_retention_seconds
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  fifo_queue                 = each.value.fifo_queue
  tags                       = var.tag_project
}

resource "aws_sqs_queue_redrive_allow_policy" "main" {
  for_each  = var.filas-sqs-deadletter
  queue_url = aws_sqs_queue.terraform_queue_deadletter[each.key].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = ["${aws_sqs_queue.terraform_queue[each.value.sqs].arn}"]
  })
}
