terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.10.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.1.2"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "aws" {
  alias      = "peer"
  region     = "eu-central-1"
  access_key = var.access_key
  secret_key = var.secret_key

  # Accepter's credentials.
}

resource "aws_vpc" "main_vpc" {
  cidr_block = var.db_vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.main_db_subnet_cidr
  availability_zone = element(var.availability_zones, 0)
  depends_on = [aws_vpc.main_vpc]
}

resource "aws_subnet" "backup_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.backup_db_subnet_cidr
  availability_zone = element(var.availability_zones, 1)
  depends_on = [aws_vpc.main_vpc]
}

resource "aws_route_table" "main_route_table" {
  vpc_id     = aws_vpc.main_vpc.id
  depends_on = [aws_vpc.main_vpc]
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  #name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.main_subnet.id, aws_subnet.backup_subnet.id]
}

resource "aws_security_group" "main_security_group" {
  name        = "allow_rds"
  description = "Allow RDS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "allow_rds"
  }
}

resource "aws_db_instance" "main_db_rds" {
  availability_zone     = element(var.availability_zones, 0)
  publicly_accessible   = false
  vpc_security_group_ids = [aws_security_group.main_security_group.id]
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name
  allocated_storage     = 10
  max_allocated_storage = 60  # enables autoscaling
  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t3.micro"
  identifier            = lower(var.db_name)
  name                  = var.db_name
  username              = var.db_username
  password              = var.db_password
  deletion_protection   = false
  skip_final_snapshot   = true  # do not make snapshot before db removal
}

resource "aws_vpc_peering_connection" "dev" {
  peer_vpc_id   = var.openshift_vpc_id  # VPC ID of dev
  peer_region   = "eu-central-1"
  vpc_id        = aws_vpc.main_vpc.id
  auto_accept   = false

  tags = {
    Created-by = "Cloudify"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.peer
  vpc_peering_connection_id = aws_vpc_peering_connection.dev.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }

  depends_on = [aws_vpc_peering_connection.dev]
}

resource "aws_route" "route_rds" {
  provider                  = aws.peer
  route_table_id            = var.openshift_route_tb_id
  destination_cidr_block    = var.db_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.dev.id
  depends_on                = [aws_vpc_peering_connection.dev]
}

resource "aws_route" "route_openshift" {
  route_table_id            = aws_route_table.main_route_table.id
  destination_cidr_block    = var.openshift_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.dev.id
  depends_on                = [aws_vpc_peering_connection.dev]
}

resource "aws_security_group_rule" "allow_rds" {
  type              = "ingress"
  from_port         = 0
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.openshift_vpc_cidr]
  security_group_id = aws_security_group.main_security_group.id
  depends_on        = [aws_security_group.main_security_group]
}

