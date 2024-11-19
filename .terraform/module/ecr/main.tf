resource "aws_ecr_repository" "main" {
  name                 = "${var.aws_prefix}-${var.aws_project}/${var.aws_env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # lifecycle {
  #   prevent_destroy = true
  # }
  tags = var.tag_project
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
  depends_on = [aws_ecr_repository.main]
}
