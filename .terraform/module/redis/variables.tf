variable "tag_project" {}
variable "redis_list" {
  type = map(any)
  default = {
    "name_redis" = {
      redis_engine          = "redis",
      redis_type            = "cache.t3.small",
      redis_nodes           = "1",
      redis_parameter_group = "default.redis6.x",
      redis_engine_version  = "6.x"
    }
  }
}
variable "security_group_ids" {
  type = list(any)
}
variable "port_redis" {}
variable "subnet_group_name" {}
