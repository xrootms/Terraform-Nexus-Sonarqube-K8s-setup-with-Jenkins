variable "ami_id" {}
variable "instance_type" {}
variable "tag_name" {}
variable "subnet_id" {}
variable "sg_for_nexus" {}
variable "enable_public_ip_address" {}
variable "user_data_install_nexus" {}
variable "key_name" {}
#variable "public_key" {}


output "nexus_ec2_instance_id" {
  value = aws_instance.nexus_ec2_instance.id
}

output "nexus_ec2_instance_public_ip" {
  value = aws_instance.nexus_ec2_instance.public_ip
}


resource "aws_instance" "nexus_ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags          = { Name = var.tag_name }

  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.sg_for_nexus
  associate_public_ip_address = var.enable_public_ip_address

  user_data = var.user_data_install_nexus

  metadata_options {
    http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
    http_tokens   = "required" # Require the use of IMDSv2 tokens
  }
}

# resource "aws_key_pair" "nexus_ec2_instance_public_key" {
#   key_name   = "devops_proj1"
#   public_key = var.public_key
# }