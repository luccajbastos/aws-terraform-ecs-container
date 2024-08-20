variable "name" {
  type        = string
  description = "The name of the environment"
}

variable "alb_custom_certificate_arn" {
  type    = string
  default = ""
}

variable "alb_custom_ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "alb_security_group_id" {
  type        = list(string)
  description = "The IDs of the Security Groups"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "The CIDR block of the VPC"
}

variable "environment" {
  type = string
}

variable "enable_alb_logs" {
  type    = bool
  default = false
}
