resource "aws_lb" "k8s_alb" {
  name                       = var.name
  internal                   = false
  load_balancer_type         = var.type
  security_groups            = var.security_groups_ids
  subnets                    = var.subnet_ids
  enable_deletion_protection = false
  # enable_cross_zone_load_balancing = true

  enable_http2 = true

  tags = {
    Name = var.name
  }
}

resource "aws_lb_listener" "k8s_listener" {
  load_balancer_arn = aws_lb.k8s_alb.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k8s_target_group.arn
  }
}

resource "aws_lb_target_group" "k8s_target_group" {
  name     = "k8s-target-group"
  port     = 6443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = 6443
  }

  tags = {
    Name = format("%s-target-group", var.name)
  }
}

resource "aws_lb_target_group_attachment" "k8s_master_attachment" {
  count            = length(var.master_ids)
  target_group_arn = aws_lb_target_group.k8s_target_group.arn
  target_id        = var.master_ids[count.index]
  port             = 6443
}
