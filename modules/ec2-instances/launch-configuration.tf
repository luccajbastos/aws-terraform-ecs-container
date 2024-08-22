data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_configuration" "asg_lc" {
  name          = "${local.name}-launch-configuration"
  image_id      = var.golden_ami_id != "" ? var.golden_ami_id : data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  security_groups = var.security_groups
  associate_public_ip_address = var.associate_public_ip

    user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd php php-mysqli
    systemctl start httpd
    systemctl enable httpd
    echo "Environment: ${local.name}" > /var/www/html/index.php
  EOF
}