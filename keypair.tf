variable "key_name" {}
variable "public_key" {}

resource "aws_key_pair" "main_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

output "key_name" {
  value = aws_key_pair.main_key.key_name
}
