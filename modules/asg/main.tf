resource "aws_lb" "web_alb" {
  name               = "web_alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.frontend_alb_sg.id]
  subnets         = [for subnet in aws_subnet.alb_subnet_public : subnet.id]

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name        = "web_alb_${terraform.workspace}"
    Environment = "${terraform.workspace}"
    Project     = "vpc-alb"
    Tier        = "frontend"
  }
}

resource "aws_lb_target_group" "web" {
  name     = "web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2

  }

  tags = {
    Name        = "web_tg_${terraform.workspace}"
    Environment = "${terraform.workspace}"
    Project     = "vpc-alb"
    Tier        = "frontend"
  }
}
