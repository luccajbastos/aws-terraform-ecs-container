
resource "aws_launch_configuration" "asg_lc" {
  count         = local.has_golden_ami
  name          = "${local.name}-launch-configuration"
  image_id      = var.golden_ami_id
  instance_type = var.instance_type
}