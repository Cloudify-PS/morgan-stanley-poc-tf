variable "aws_region" {
  type = string
  description = "AWS region to launch servers."
}

variable "access_key" {
  type = string
  description = "Access key for AWS"
}

variable "secret_key" {
  type = string
  description = "Secret key for AWS"
}

variable "availability_zones" {
  type = list
  description = "ELB availability zones"
}

variable "db_name" {
  type = string
  description = "Name of the database to be created"
}

variable "db_username" {
  type = string
  description = "Name of the database user"
}

variable "db_password" {
  type = string
  description = "Password of the database user"
}

variable "openshift_vpc_id" {
  type = string
  description = "ID of Openshift cluster VPC"
}

variable "openshift_route_tb_id" {
  type = string
  description = "ID of Openshift cluster route table"
}

variable "openshift_public_subnet_id" {
  type = string
  description = "ID of Openshift cluster public subnet"
}

variable "openshift_security_group_id" {
  type = string
  description = "ID of Openshift cluster security group"
}

variable "openshift_instances" {
  type = list
  description = "List of Openshift cluster instances"
}

variable "openshift_vpc_cidr" {
  type = string
  description = "CIDR of Openshift cluster VPC"
}

variable "db_vpc_cidr" {
  type = string
  description = "CIDR of RDS VPC"
}

variable "main_db_subnet_cidr" {
  type = string
  description = "CIDR of RDS VPC"
}

variable "backup_db_subnet_cidr" {
  type = string
  description = "CIDR of RDS VPC"
}
