terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.37.0"
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

resource "aws_lb" "main_lb" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.public_subnet_id]

  tags = {
    Created-by= "Cloudify"
  }
}

resource "aws_lb_target_group" "openshift_http" {
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  preserve_client_ip = true

  tags = {
    "kubernetes.io/service-name" = "default/my-nginx-controller"
    "kubernetes.io/cluster/os-cb-cluster1-9j45k" = "owner"
    "kubernetes.io/cluster/os-cb-cluster3-7h6p9" = "owner"
  }
}

resource "aws_lb_target_group_attachment" "http_cluster_a_worker_0" {
  target_group_arn = aws_lb_target_group.openshift_http.arn
  target_id        = var.cluster_a[0].ip
  port             = var.cluster_a[0].http_port
  availability_zone = var.cluster_a[0].availability_zone
  depends_on       = [aws_lb_target_group.openshift_http]
}

resource "aws_lb_target_group_attachment" "http_cluster_a_worker_1" {
  target_group_arn = aws_lb_target_group.openshift_http.arn
  target_id        = var.cluster_a[1].ip
  port             = var.cluster_a[1].http_port
  availability_zone = var.cluster_a[1].availability_zone
  depends_on       = [aws_lb_target_group.openshift_http]
}

resource "aws_lb_target_group_attachment" "http_cluster_b_worker_0" {
  target_group_arn = aws_lb_target_group.openshift_http.arn
  target_id        = var.cluster_b[0].ip
  port             = var.cluster_b[0].http_port
  availability_zone = var.cluster_b[0].availability_zone
  depends_on       = [aws_lb_target_group.openshift_http]
}

resource "aws_lb_target_group_attachment" "http_cluster_b_worker_1" {
  target_group_arn = aws_lb_target_group.openshift_http.arn
  target_id        = var.cluster_b[1].ip
  port             = var.cluster_b[1].http_port
  availability_zone = var.cluster_b[1].availability_zone
  depends_on       = [aws_lb_target_group.openshift_http]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_lb.arn
  port = "80"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.openshift_http.arn
  }
}

resource "aws_lb_target_group" "openshift_https" {
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  preserve_client_ip = true

  tags = {
    "kubernetes.io/service-name" = "default/my-nginx-controller"
    "kubernetes.io/cluster/os-cb-cluster1-9j45k" = "owner"
    "kubernetes.io/cluster/os-cb-cluster3-7h6p9" = "owner"
  }
}

resource "aws_lb_target_group_attachment" "https_cluster_a_worker_0" {
  target_group_arn = aws_lb_target_group.openshift_https.arn
  target_id        = var.cluster_a[0].ip
  port             = var.cluster_a[0].https_port
  availability_zone = var.cluster_a[0].availability_zone
  depends_on       = [aws_lb_target_group.openshift_https]
}

resource "aws_lb_target_group_attachment" "https_cluster_a_worker_1" {
  target_group_arn = aws_lb_target_group.openshift_https.arn
  target_id        = var.cluster_a[1].ip
  port             = var.cluster_a[1].https_port
  availability_zone = var.cluster_a[1].availability_zone
  depends_on       = [aws_lb_target_group.openshift_https]
}

resource "aws_lb_target_group_attachment" "https_cluster_b_worker_0" {
  target_group_arn = aws_lb_target_group.openshift_https.arn
  target_id        = var.cluster_b[0].ip
  port             = var.cluster_b[0].https_port
  availability_zone = var.cluster_b[0].availability_zone
  depends_on       = [aws_lb_target_group.openshift_https]
}

resource "aws_lb_target_group_attachment" "https_cluster_b_worker_1" {
  target_group_arn = aws_lb_target_group.openshift_https.arn
  target_id        = var.cluster_b[1].ip
  port             = var.cluster_b[1].https_port
  availability_zone = var.cluster_b[1].availability_zone
  depends_on       = [aws_lb_target_group.openshift_https]
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.main_lb.arn
  port = "443"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.openshift_https.arn
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"
  
  alias {
    name                   = aws_lb.main_lb.dns_name
    zone_id                = aws_lb.main_lb.zone_id
    evaluate_target_health = true
  }

  depends_on = [aws_lb.main_lb]
}

