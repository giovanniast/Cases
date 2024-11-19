
variable "tag_project" {}

variable "filas-sqs" {
  type = map(any)
  default = {
    "name_fila" = { delay_seconds = "0", max_message_size = "262144", message_retention_seconds = "864000", receive_wait_time_seconds = "0", visibility_timeout_seconds = "30", deadletter = null }
  }
}
variable "filas-sqs-deadletter" {
  type = map(any)
  default = {
    "name_fila_deadletter" = { sqs = "fila", message_retention_seconds = "345600", visibility_timeout_seconds = "30" }
  }
}
