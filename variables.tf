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

variable "lb_name" {
  type = string
  description = "Name of the Elastic Load Balancer to be created"
}

variable "domain_name" {
  type = string
  description = "Name of the domain in Route53"
}

variable "zone_id" {
  type = string
  description = "Zone ID of the domain in Route53"
}

variable "vpc_id" {
  type = string
  description = "ID of the Openshift VPC"
}

variable "public_subnet_id" {
  type = string
  description = "ID of the Openshift public subnet"
}

variable "cluster_a" {
  type = list(map(string))
  description = "List of cluster A worker nodes"
}

variable "cluster_b" {
  type = list(map(string))
  description = "List of cluster B worker nodes"
}