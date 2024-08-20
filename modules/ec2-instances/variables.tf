variable "name" {
  type = string
}

variable "max_capacity" {
  type = number
}

variable "min_capacity" {
  type = number
}

variable "golden_ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "app_subnets_ids" {
  type = list(string)
}

variable "golden_ec2_config" {
  type = object({
    create = bool
    security_groups = list(string)
    subnet_id = string
    key_name = string
  })
}

variable "app_port" {
  type = number
}

variable "app_protocol" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "health_check_config" {
  type = object({
    enabled             = bool
    healthy_threshold   = number
    unhealthy_threshold = number
    path                = string
    port                = number
    protocol            = string
    interval = number
  })
}

variable "tags" {
  type = map(string)
}