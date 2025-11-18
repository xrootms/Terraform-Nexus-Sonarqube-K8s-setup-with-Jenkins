module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  ap_availability_zone = var.ap_availability_zone
  cidr_private_subnet  = var.cidr_private_subnet

}

module "security_groups" {
  source              = "./security-groups"
  ec2_sg_name         = "SG for EC2 to enable SSH(22), HTTPS(443) and HTTP(80)"
  vpc_id              = module.networking.devops_proj_1_vpc_id
  ec2_jenkins_sg_name = "Allow port 8080 for jenkins"
  ec2_sonar_sg_name   = "Allow port 9000 for sonar"
  ec2_nexus_sg_name   = "Allow port 8081 for nexus"
  k8s_cluster_sg_name = "SG for k8s to enable 465, 30000-32767, 25, 3000-10000 & 6443"
}

# module "jenkins" {
#   source                    = "./jenkins"
#   ami_id                    = var.ec2_ami_id
#   instance_type             = "t2.micro"
#   tag_name                  = "Jenkins:Ubuntu 22.04 EC2"
#   subnet_id                 = tolist(module.networking.devops_proj_1_public_subnets_id)[0]
#   sg_for_jenkins            = [module.security_groups.sg_ec2_sg_ssh_http_https_id, module.security_groups.sg_ec2_jenkins_port_8080_id]
#   enable_public_ip_address  = true
#   user_data_install_jenkins = templatefile("./jenkins/jenkins-runner-script/jenkins-installer.sh", {})
#   key_name                  = aws_key_pair.main_key.key_name
# }

# module "sonar" {
#   source                    = "./sonar"
#   ami_id                    = var.ec2_ami_id
#   instance_type             = "t2.micro"
#   tag_name                  = "Sonar:Ubuntu 22.04 EC2"
#   subnet_id                 = tolist(module.networking.devops_proj_1_public_subnets_id)[0]
#   sg_for_sonar              = [module.security_groups.sg_ec2_sg_ssh_http_https_id, module.security_groups.sg_ec2_sonar_port_9000_id]
#   enable_public_ip_address  = true
#   user_data_install_sonar   = templatefile("./sonar/sonar-runner-script/sonar-installer.sh", {})
#   key_name                  = aws_key_pair.main_key.key_name
# }

# module "nexus" {
#   source                    = "./nexus"
#   ami_id                    = var.ec2_ami_id
#   instance_type             = "t2.micro"
#   tag_name                  = "Nexus:Ubuntu 22.04 EC2"
#   subnet_id                 = tolist(module.networking.devops_proj_1_public_subnets_id)[0]
#   sg_for_nexus              = [module.security_groups.sg_ec2_sg_ssh_http_https_id, module.security_groups.sg_ec2_nexus_port_8081_id]
#   enable_public_ip_address  = true
#   user_data_install_nexus   = templatefile("./nexus/nexus-runner-script/nexus-installer.sh", {})
#   key_name                  = aws_key_pair.main_key.key_name
# }

module "kubeadm-cluster" {
  source            = "./kubeadm-cluster"
  ami_id            = var.ec2_ami_id
  instance_type     = "t3.small"
  tag_cluster_name  = "Devops"
  subnet_id         = tolist(module.networking.devops_proj_1_public_subnets_id)[0]
  sg_for_k8s        = [module.security_groups.sg_ec2_sg_ssh_http_https_id, module.security_groups.sg_ec2_k8s_cluster_id]
  enable_public_ip_address  = true
  user_data_install_k8s_master = templatefile("./kubeadm-cluster/kubeadm-runner-script/master.sh", {})
  user_data_install_k8s_worker = templatefile("./kubeadm-cluster/kubeadm-runner-script/worker.sh", {})
  key_name                  = aws_key_pair.main_key.key_name  
}
