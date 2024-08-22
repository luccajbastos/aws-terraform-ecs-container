resource "aws_lb_listener_rule" "app_rule" {
  listener_arn = var.alb_listener_arn
  priority     = var.alb_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.golden_tg.arn
  }
  
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
