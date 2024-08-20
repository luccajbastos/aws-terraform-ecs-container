locals {
  tags = merge(var.tags, {
    Name = "${var.name}-golden"
  })

  create_golden_ec2 = var.golden_ec2_config["create"] == true ? 1 : 0
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "golden_ec2" {
  count         = local.create_golden_ec2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "m6i.large"
  key_name = var.golden_ec2_config["key_name"]

  network_interface {
    network_interface_id = aws_network_interface.golden_ec2_network_interface[0].id
    device_index = 0
  }

  tags = local.tags

}

resource "aws_network_interface" "golden_ec2_network_interface" {
  count         = local.create_golden_ec2
  subnet_id   = var.golden_ec2_config["subnet_id"]
  security_groups = var.golden_ec2_config["security_groups"]
  tags = local.tags
}

resource "aws_eip" "goldenip" {
  count         = local.create_golden_ec2
  instance = aws_instance.golden_ec2[0].id
}