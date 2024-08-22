variable "name" {
  type = string
}

variable "path_patterns" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}
variable "alb_listener_arn" {
  type = string
}

variable "desired_capacity" {
  type = number
}

variable "alb_rule_priority" {
  type = number
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

variable "associate_public_ip" {
  type = bool
}