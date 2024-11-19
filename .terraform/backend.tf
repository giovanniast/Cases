#config da região e profile
provider "aws" {
  region      = var.aws_region
  profile     = var.aws_profile
  max_retries = 8
}

#modulos terraform
terraform {
  required_version = "1.3.0"
  #required_version = "1.5.1"
  backend "s3" {}

  required_providers {
    aws    = "4.50.0"
    local  = ">=2.1.0"
    random = "3.3.2"
    null   = "3.2.1"
  }
}
