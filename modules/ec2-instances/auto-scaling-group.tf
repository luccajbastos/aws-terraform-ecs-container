locals {
  name           = "${var.name}-asg"
}

resource "aws_autoscaling_group" "auto-scaling" {
  depends_on = [ aws_launch_configuration.asg_lc ]
  name                      = local.name
  max_size                  = var.max_capacity
  min_size                  = var.min_capacity
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  launch_configuration      = aws_launch_configuration.asg_lc.name
  vpc_zone_identifier       = var.app_subnets_ids
  target_group_arns         = ["${aws_lb_target_group.golden_tg.arn}"]

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }
}