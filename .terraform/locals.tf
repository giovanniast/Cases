locals {
  vars = {
    DATABASE_URL                  = var.aws_env == "production" ? var.DATABASE_URL : "postgresql://${one(module.rds[0].master_username)}:${try(var.password_rds, random_password.password.result)}@${one(module.rds[0].endpoint)}:${var.port_rds}/coach?pool=8&encoding=utf8"
    AWS_REGION                    = "${var.aws_region}"
    REDIS_URL                     = var.aws_env == "production" ? var.REDIS_URL : "redis://${one(module.redis[0].endpoint)}:${var.port_redis}"
  }
  depends_on = [
    random_password.password,
    module.secret-manager,
    module.iam,
    module.rds
  ]
}
