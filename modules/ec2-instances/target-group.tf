resource "aws_lb_target_group" "golden_tg" {
  name     = "${local.name}-tg"
  port     = var.app_port
  protocol = var.app_protocol != "" ? var.app_protocol : "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled           = var.health_check_config["enabled"]
    healthy_threshold = var.health_check_config["healthy_threshold"]
    interval          = var.health_check_config["interval"]
    path              = var.health_check_config["path"]
    port              = var.health_check_config["port"]
    protocol          = var.health_check_config["protocol"]
  }
}