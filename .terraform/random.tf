resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_!$"
}

resource "random_id" "tg-name" {
  byte_length = 2
}
