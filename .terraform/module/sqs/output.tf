output "filas" {
  value = [for v in aws_sqs_queue.terraform_queue : v.name]
}

output "filas-url" {
  value = { for k, v in aws_sqs_queue.terraform_queue : k => v.url }
}

output "filas-deadletter" {
  value = [for v in aws_sqs_queue.terraform_queue_deadletter : v.name]
}

output "url-region" {
  value = element(split("/", tolist([for v in aws_sqs_queue.terraform_queue : v.id])[0]), 2)
}
