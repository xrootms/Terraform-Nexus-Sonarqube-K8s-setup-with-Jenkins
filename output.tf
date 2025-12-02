

# output "ssh_connection_string_for_ec2_sonar" {
#   value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.sonar.sonar_ec2_instance_public_ip}"
# }

# output "ssh_connection_string_for_ec2_nexus" {
#   value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.nexus.nexus_ec2_instance_public_ip}"
# }

output "ssh_connection_string_for_k8s_master" {
  value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.kubeadm-cluster.master_public_ip}"
}


output "ssh_connection_string_for_k8s_worker_01" {
  value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.kubeadm-cluster.worker_public_ips[0]}"
}

# output "ssh_connection_string_for_k8s_worker_02" {
#   value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.kubeadm-cluster.worker_public_ips[1]}"
# }




# output "ssh_connection_string_for_k8s_worker_01" {
#   value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.kubeadm-cluster.first_worker_01_public_ip}"
# }

# output "ssh_connection_string_for_k8s_worker_02" {
#   value = "ssh -i ~/Documents/keys/devops_proj1 ubuntu@${module.kubeadm-cluster.second_worker_02_public_ip}"
# }


