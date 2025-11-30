variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "ec2_sonar_sg_name" {}
variable "ec2_nexus_sg_name" {}
variable "sg_ports" { default = [22, 80, 443] }

variable "k8s_cluster_sg_name" {}
variable "k8s_cluster_sg_ports" {
  default = [
    { from = 25,     to = 25 },        #SMTP
    { from = 465,    to = 465 },       #SMTPS
    { from = 6443,   to = 6443 },      # Kubernetes API server
    { from = 3000,   to = 10000 },     # App / NodePort range (custom)
    { from = 30000,  to = 32767 },     # Kubernetes NodePort range
  ]
}

output "sg_ec2_sg_ssh_http_https_id" {
  value = aws_security_group.ec2_sg_ssh_http_https.id
}


output "sg_ec2_sonar_port_9000_id" {
  value = aws_security_group.ec2_sonar_port_9000.id
}

output "sg_ec2_nexus_port_8081_id" {
  value = aws_security_group.ec2_nexus_port_8081.id
}



output "sg_ec2_k8s_cluster_id" {
  value = aws_security_group.k8s_cluster_sg.id
}


#----SG for ports: 22, 80, 443----
resource "aws_security_group" "ec2_sg_ssh_http_https" {
  name        = var.ec2_sg_name
  vpc_id      = var.vpc_id
  description = "Enable the Port 22(SSH), Port 80(http) & port 443(https)"

  #Allow all outbound traffic 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing request to anywhere"
  }
  tags = { Name = "Security Group: SSH(22), HTTP(80) and HTTPs(443)" }
}

#Ingress rules using count
resource "aws_security_group_rule" "sg_ingress" {
  count             = length(var.sg_ports)
  type              = "ingress"
  from_port         = var.sg_ports[count.index]
  to_port           = var.sg_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_sg_ssh_http_https.id
  description       = "Allow port ${var.sg_ports[count.index]} from anywhere"
}



#----SG for sonar port 9000----
resource "aws_security_group" "ec2_sonar_port_9000" {
  name        = var.ec2_sonar_sg_name
  description = "Enable the Port 9000 for sonar"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # security_groups = [ALB Security Group ID] ,Only ALB can reach Sonar:9000
    description = "Allow 9000 port to access sonar from anywhere"
  }
  tags = { Name = "Sonar SG: 9000" }
}



#----SG for nexus port 8081----
resource "aws_security_group" "ec2_nexus_port_8081" {
  name        = var.ec2_nexus_sg_name
  description = "Enable the Port 8081 for nexus"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # security_groups = [ALB Security Group ID] ,Only ALB can reach Nexus:8081
    description = "Allow 8081 port to access nexus from anywhere"
  }
  tags = { Name = "Nexus SG: 8081" }
}




#----SG for k8s ports: 465, 30000-32767, 25, 3000-10000 & 6443----
resource "aws_security_group" "k8s_cluster_sg" {
  name        = var.k8s_cluster_sg_name
  vpc_id      = var.vpc_id
  description = "Enable the Port 465, 30000-32767, 25, 3000-10000 & 6443"

  #Allow all outbound traffic 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing request to anywhere"
  }
  tags = { Name = "Security Group: 465, 30000-32767, 25, 3000-10000 & 6443" }
}

#Ingress rules using count
resource "aws_security_group_rule" "k8s_cluster_sg_ingress" {
  count             = length(var.k8s_cluster_sg_ports)
  type              = "ingress"
  from_port         = var.k8s_cluster_sg_ports[count.index].from
  to_port           = var.k8s_cluster_sg_ports[count.index].to
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_cluster_sg.id
  description       = "Allow ports ${var.k8s_cluster_sg_ports[count.index].from}-${var.k8s_cluster_sg_ports[count.index].to} from anywhere"
}


