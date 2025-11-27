
variable "ami_id" {}
variable "instance_type" {}
variable "tag_cluster_name" {}
variable "subnet_id" {}
variable "sg_for_k8s" {}
variable "enable_public_ip_address" {}
variable "user_data_install_k8s_master" {}
variable "user_data_install_k8s_worker" {}
variable "key_name" {}


output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "first_worker_01_public_ip" {
  value = aws_instance.worker[0].public_ip
}

# output "second_worker_02_public_ip" {
#   value = aws_instance.worker[1].public_ip
# }

# output "worker_public_ips" {
#   value = [for w in aws_instance.worker : w.public_ip]                       ##for-expression (like a for loop), Give a list of IDs for all
# }



resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.sg_for_k8s
  associate_public_ip_address = var.enable_public_ip_address

  tags = {
    Name = "${var.tag_cluster_name}-master"
  }

  user_data = var.user_data_install_k8s_master
}

resource "aws_instance" "worker" {
  count                  = 1
  ami                    = var.ami_id
  instance_type          = var.instance_type

  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = var.sg_for_k8s
  associate_public_ip_address = var.enable_public_ip_address

  tags = {
    Name = "${var.tag_cluster_name}-worker-${count.index + 1}"
  }

  user_data = var.user_data_install_k8s_worker
}




# output "worker_public_ips" {
#   value = [for w in aws_instance.worker : w.public_ip]                       ##for-expression (like a for loop), Give a list of IDs for all
# }




#human-readable instructions for what to do after the cluster setup is done.
# output "manual_join_note" {
#   value = <<EOT
# After the cluster is initialized, SSH into the master:
#   ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.master.public_ip}     

# Get the join command:
#   sudo cat /tmp/join-command.sh

# Then SSH into each worker and run the command:
#   ssh -i ~/.ssh/id_rsa ubuntu@<worker-ip>
#   sudo <paste-join-command>
# EOT
# }
