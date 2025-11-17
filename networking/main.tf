variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "ap_availability_zone" {}
variable "cidr_private_subnet" {}

output "devops_proj_1_vpc_id" {
  value = aws_vpc.devops_proj_1_vpc.id
}

output "devops_proj_1_public_subnets_id" {                      #it returns a list of all subnet IDs
  value = aws_subnet.devops_proj_1_public_subnets.*.id          # “splat” (*.) syntax, Give a list of IDs for all
}

output "public_subnet_cidr_block" {
  value = aws_subnet.devops_proj_1_public_subnets.*.cidr_block
}

#setup vpc

resource "aws_vpc" "devops_proj_1_vpc" {
    cidr_block = var.vpc_cidr
    tags = { Name = var.vpc_name }
}

# setup public subnet

resource "aws_subnet" "devops_proj_1_public_subnets" {
    count = length(var.cidr_public_subnet)
    vpc_id = aws_vpc.devops_proj_1_vpc.id
    cidr_block = element(var.cidr_public_subnet, count.index)
    availability_zone = element(var.ap_availability_zone, count.index)
    tags = { Name = "devops_proj_1_public_subnet-${count.index + 1}" }
  
}

# setup private subnet

resource "aws_subnet" "devops_proj_1_private_subnets" {
    count = length(var.cidr_private_subnet)
    vpc_id = aws_vpc.devops_proj_1_vpc.id 
    cidr_block = element(var.cidr_private_subnet, count.index)
    availability_zone = element(var.ap_availability_zone, count.index)
    tags = { Name = "devops_proj_1_private_subnet-${count.index + 1}" }
}

# Setup Internet Gateway

resource "aws_internet_gateway" "devops_proj_1_ig" {
    vpc_id = aws_vpc.devops_proj_1_vpc.id
    tags = { Name = "devops_proj_1_ig" }

}

# public route_table

resource "aws_route_table" "devops_proj_1_public_route_table" {
    vpc_id = aws_vpc.devops_proj_1_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.devops_proj_1_ig.id
    }
    tags = { Name = "devops_proj_1_public_rt" }
}

# Public Route_Table and Public Subnet Association

resource "aws_route_table_association" "devops_proj_1_public_rt_subnet_association" {
    count = length(aws_subnet.devops_proj_1_public_subnets)
    subnet_id = aws_subnet.devops_proj_1_public_subnets[count.index].id
    route_table_id = aws_route_table.devops_proj_1_public_route_table.id
}

# Private Route Table

resource "aws_route_table" "devops_proj_1_private_route_table" {
    vpc_id = aws_vpc.devops_proj_1_vpc.id
     #depends_on = [aws_nat_gateway.nat_gateway]
    tags = { Name = "devops_proj_1_private_rt" }
}

# Private Route_Table and private Subnet Association

resource "aws_route_table_association" "devops_proj_1_private_rt_subnet_association" {
    count = length(aws_subnet.devops_proj_1_private_subnets)
    subnet_id = aws_subnet.devops_proj_1_private_subnets[count.index].id
    route_table_id = aws_route_table.devops_proj_1_private_route_table.id

}