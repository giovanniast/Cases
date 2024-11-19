#IAM
resource "aws_secretsmanager_secret" "iam" {
  name        = "${var.aws_prefix}-${var.aws_project}/iam"
  description = "key and secret ${var.aws_project}"
  tags        = var.tag_project
}

resource "aws_secretsmanager_secret_version" "iam" {
  secret_id = aws_secretsmanager_secret.iam.id
  secret_string = jsonencode(
    var.list_access_key
  )
}

#Captura o dados do secret-manager da conta default do secretmanager.
data "aws_secretsmanager_secret_version" "app" {
  secret_id  = aws_secretsmanager_secret.app.arn
  depends_on = [aws_secretsmanager_secret.app]
}

#Resultado da secrets da conta default do secretmanager.
locals {
  detination_results = try(merge(
    jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.app.secret_string))
  ), null)
  depends_on = [
    data.aws_secretsmanager_secret_version.app
  ]
}

#APP
resource "aws_secretsmanager_secret" "app" {
  name        = "${var.aws_prefix}-${var.aws_project}/app/${var.aws_env}"
  description = "key and secret project ${var.aws_project}"
  tags        = var.tag_project
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode(
    var.enable_secret_sync ? merge(local.detination_results, var.list_secret_app) : local.detination_results
  )
  depends_on = [
    aws_secretsmanager_secret.app
  ]
}
