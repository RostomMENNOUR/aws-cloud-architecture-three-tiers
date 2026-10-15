resource "aws_lb" "app_alb_3-tiers" {
  name               = "app-load-balancer-3-tiers"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg_3-tiers.id]
  
  subnets            = [
    aws_subnet.public_subnet_a.id, 
    aws_subnet.public_subnet_b.id
  ]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_3_tires_project.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_alb_3-tiers.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}