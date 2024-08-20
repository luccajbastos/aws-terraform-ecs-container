locals {
  name           = "${var.name}-asg"
  has_golden_ami = var.golden_ami_id != "" ? 1 : 0
}

resource "aws_autoscaling_group" "auto-scaling" {
  count                     = local.has_golden_ami
  name                      = local.name
  max_size                  = var.max_capacity
  min_size                  = var.min_capacity
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  launch_configuration      = aws_launch_configuration.asg_lc[0].name
  vpc_zone_identifier       = var.app_subnets_ids
  target_group_arns         = ["${aws_lb_target_group.golden_tg.arn}"]
}