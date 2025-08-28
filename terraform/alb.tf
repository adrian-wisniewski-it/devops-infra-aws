resource "aws_lb" "devops_alb" {
  name               = "devops-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.devops_alb_sg.id]
  subnets = [ 
    aws_subnet.devops_public_1.id,
    aws_subnet.devops_public_2.id
  ]

  tags = {
    Name = "devops-alb"
  }
}

resource "aws_lb_target_group" "devops_lb_tg" {
  name     = "devops-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.devops_vpc.id

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "devops-lb-tg"
  }
}

resource "aws_lb_listener" "devops_lb_listener" {
  load_balancer_arn = aws_lb.devops_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devops_lb_tg.arn
  }
}


resource "aws_lb_target_group_attachment" "devops_tg_attachment" {
  target_group_arn = aws_lb_target_group.devops_lb_tg.arn
  target_id        = aws_instance.devops_instance[0].id
  port            = 80
}