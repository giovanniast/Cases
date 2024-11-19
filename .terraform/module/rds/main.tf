data "aws_availability_zones" "available" {}
resource "null_resource" "region" {
  count = length(var.mask_priv)
  triggers = {
    region = data.aws_availability_zones.available.names[count.index]
  }
}

data "aws_kms_key" "this" { key_id = "alias/aws/rds" }

resource "aws_rds_cluster" "main" {
  for_each                  = var.config_rds
  cluster_identifier        = "${var.aws_prefix}-${each.key}-${var.aws_env}"
  engine                    = each.value.engine
  engine_version            = each.value.engine_version
  engine_mode               = each.value.engine_mode
  availability_zones        = [for k, v in null_resource.region[*].triggers : v.region]
  database_name             = each.value.database_name
  master_username           = each.value.master_username
  master_password           = var.master_password
  backup_retention_period   = 7
  port                      = var.port_rds
  vpc_security_group_ids    = [var.vpc_security_group_ids]
  db_subnet_group_name      = "${var.aws_prefix}-${each.key}-${var.aws_env}"
  skip_final_snapshot       = false
  copy_tags_to_snapshot     = true
  final_snapshot_identifier = "${var.aws_prefix}-${each.key}-${var.aws_env}-final-terraform"
  storage_encrypted         = true
  kms_key_id                = try(each.value.kms_key_id, data.aws_kms_key.this.arn)
  apply_immediately         = true
  tags = merge(
    var.tag_project,
    {
      "DBSSR-DevStag"                = "${var.aws_prefix}-${each.key}-${var.aws_env}"
      "DBSSR-DevStagInstanceClass"   = "${each.value.instance_class}"
      "StartStop-${var.aws_project}" = " "
    }
  )
  lifecycle {
    ignore_changes = [
      engine_version,
      availability_zones,
      kms_key_id
    ]
    prevent_destroy = true
  }
}

# COUNT COM FOR
locals {
  data = { for i in flatten([
    for k, x in var.config_rds :
    [
      for y in range(x.cluster_instance_count) :
      {
        "name"            = k
        "id"              = y
        "master_username" = x.master_username
        "database_name"   = x.database_name
        "instance_class"  = x.instance_class
        "engine"          = x.engine
        "engine_version"  = x.engine_version
        "engine_mode"     = x.engine_mode
      }
    ]
    ]) : "${i.name}-${i.id}" => i
  }
}


resource "aws_rds_cluster_instance" "main" {
  for_each                     = local.data
  identifier                   = "${var.aws_prefix}-${each.key}"
  cluster_identifier           = aws_rds_cluster.main[each.value.name].id
  instance_class               = each.value.instance_class
  engine                       = aws_rds_cluster.main[each.value.name].engine
  engine_version               = aws_rds_cluster.main[each.value.name].engine_version
  performance_insights_enabled = true
  apply_immediately            = true
  promotion_tier               = each.value.id
  tags = merge(
    var.tag_project,
    {
      "DBSSR-DevStag"              = "${var.aws_prefix}-${each.key}-${var.aws_env}"
      "DBSSR-DevStagInstanceClass" = "${each.value.instance_class}"
    }
  )
  lifecycle {
    ignore_changes = [
      engine_version
    ]
    prevent_destroy = true
  }
}