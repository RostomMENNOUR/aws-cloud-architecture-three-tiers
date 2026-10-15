resource "aws_security_group" "alb_sg_3-tiers" {
  name        = "alb_sg"
  description = "allow the ALB to be accessible from internet"
  vpc_id      = aws_vpc.vpc_3_tires_project.id

  tags = {
    Name = "alb_sg_3-tiers"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4_alb" {
  security_group_id = aws_security_group.alb_sg_3-tiers.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4_alb" {
  security_group_id = aws_security_group.alb_sg_3-tiers.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_security_group" "app_sg_3-tiers" {
    name = "app_sg"
    vpc_id = aws_vpc.vpc_3_tires_project.id
    tags = {
        Name = "app_sg_3-tiers"
    }
}

resource "aws_vpc_security_group_ingress_rule" "app_alb" {
  security_group_id = aws_security_group.app_sg_3-tiers.id
  referenced_security_group_id = aws_security_group.alb_sg_3-tiers.id
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4_app" {
  security_group_id = aws_security_group.app_sg_3-tiers.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_security_group" "db_sg_3-tiers" {
    name = "db_sg"
    vpc_id = aws_vpc.vpc_3_tires_project.id
    tags = {
        Name = "db_sg_3-tiers"
    }
}

resource "aws_vpc_security_group_ingress_rule" "db_app" {
  security_group_id = aws_security_group.db_sg_3-tiers.id
  referenced_security_group_id = aws_security_group.app_sg_3-tiers.id
  from_port = 3306
  to_port = 3306
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4_db" {
  security_group_id = aws_security_group.db_sg_3-tiers.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol       = -1
}