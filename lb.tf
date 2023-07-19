resource "aws_lb" "nlb" {
  name                             = "${var.app_name}-nlb"
  load_balancer_type               = "network"
  subnets                          = aws_subnet.public_subnet.*.id
  internal                         = false
  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn

  protocol = "TCP"
  port     = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}

resource "aws_lb_target_group" "nlb_target_group" {
  name                   = "${var.app_name}-nlb-target"
  port                   = var.container_port
  protocol               = "TCP"
  vpc_id                 = aws_vpc.vpc.id
  target_type            = "ip"
  connection_termination = true
  deregistration_delay   = 10
  stickiness {
    enabled = true
    type    = "source_ip"
  }

  depends_on = [
    aws_lb.nlb
  ]

  health_check {
    enabled             = true
    interval            = 30
    path                = "/actuator/health"
    timeout             = 10
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}


#resource "aws_lb" "alb" {
#  name               = "${var.app_name}-alb"
#  subnets            = aws_subnet.public_subnet.*.id
#  load_balancer_type = "application"
#  security_groups    = [aws_security_group.alb_sg.id]
#
#  #  access_logs {
#  #    bucket  = aws_s3_bucket.log_storage.id
#  #    prefix  = "frontend-alb"
#  #    enabled = true
#  #  }
#  #
#  #  tags = {
#  #    Environment = "staging"
#  #    Application = var.app_name
#  #  }
#}
#
#resource "aws_lb_listener" "alb_listener" {
#  load_balancer_arn = aws_lb.alb.arn
#  port              = 80
#  protocol          = "HTTP"
#
#  default_action {
#    target_group_arn = aws_lb_target_group.alb_target_group.id
#    type             = "forward"
#  }
#
#  #  default_action {
#  #    type = "redirect"
#  #
#  #    redirect {
#  #      port        = "443"
#  #      protocol    = "HTTPS"
#  #      status_code = "HTTP_301"
#  #    }
#  #  }
#}
#
#
#resource "aws_lb_target_group" "alb_target_group" {
#  name        = "${var.app_name}-alb-target-group"
#  port        = 80
#  protocol    = "HTTP"
#  vpc_id      = aws_vpc.vpc.id
#  target_type = "ip"
#
#  health_check {
#    enabled             = true
#    interval            = 300
#    path                = "/actuator/health"
#    timeout             = 60
#    matcher             = "200"
#    healthy_threshold   = 5
#    unhealthy_threshold = 5
#  }
#
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#
##resource "aws_lb_listener" "https_forward" {
##  load_balancer_arn = aws_lb.staging.arn
##  port              = 443
##  protocol          = "HTTPS"
##  certificate_arn   = aws_acm_certificate.cert.arn
##  ssl_policy        = "ELBSecurityPolicy-2016-08"
##
##  default_action {
##    type             = "forward"
##    target_group_arn = aws_lb_target_group.staging.arn
##  }
##}
