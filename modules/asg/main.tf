# web application load balancer
resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.frontend_alb_sg_id]
  subnets         = var.public_subnets

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
  vpc_id   = var.vpc_id

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


# web launch template
resource "aws_launch_template" "web" {
  name_prefix = "${terraform.workspace}_web"

  image_id      = var.image_id
  instance_type = var.web_instance_type

  user_data = var.user_data_base64




  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "web_${terraform.workspace}"
      Environment = "${terraform.workspace}"
      Project     = "vpc-alb"
      Tier        = "frontend"
    }
  }

}


resource "aws_autoscaling_group" "web" {
  name_prefix = "${terraform.workspace}_web"

  vpc_zone_identifier = var.web_private_subnets

  desired_capacity = 2

  min_size = 2
  max_size = 4

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.id]

  tag {
    key                 = "Name"
    value               = "web_${terraform.workspace}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = terraform.workspace
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = "vpc-alb"
    propagate_at_launch = true
  }
  tag {
    key                 = "Tier"
    value               = "frontend"
    propagate_at_launch = true
  }

}


# App ALB (Internal)

resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [var.backend_alb_sg_id]
  subnets         = var.public_subnets

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name        = "app_alb_${terraform.workspace}"
    Environment = "${terraform.workspace}"
    Project     = "vpc-alb"
    Tier        = "backend"
  }
}


resource "aws_lb_target_group" "app" {
  name     = "app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

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
    Name        = "app_tg_${terraform.workspace}"
    Environment = "${terraform.workspace}"
    Project     = "vpc-alb"
    Tier        = "backend"
  }
}


resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app_alb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.id
  }

}

# app launch template and asg

resource "aws_launch_template" "app" {
  name_prefix = "${terraform.workspace}_app"

  image_id      = var.image_id
  instance_type = var.app_instance_type

  user_data = var.user_data_base64



  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "app_${terraform.workspace}"
      Environment = "${terraform.workspace}"
      Project     = "vpc-alb"
      Tier        = "backend"
    }
  }



}

resource "aws_autoscaling_group" "app" {
  name_prefix = "${terraform.workspace}_app"

  vpc_zone_identifier = var.app_private_subnets

  desired_capacity = 2

  min_size = 2
  max_size = 4

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.id]

  tag {
    key                 = "Name"
    value               = "app_${terraform.workspace}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = terraform.workspace
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = "vpc-alb"
    propagate_at_launch = true
  }
  tag {
    key                 = "Tier"
    value               = "backend"
    propagate_at_launch = true
  }


}
