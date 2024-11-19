output "iam_arn" {
  value = aws_secretsmanager_secret.iam.arn
}
output "app_arn" {
  value = aws_secretsmanager_secret.app.arn
}
