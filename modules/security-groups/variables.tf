variable "config" {
  type = object({
    create_efs_security_group = bool
    create_app_security_group = bool
    create_db_security_group  = bool
    create_alb_security_group = bool
  })

}

variable "admin_ips" {
  type = list(object({
    ip = string
    description = string
  }))

}

variable "name" {
  type        = string
  description = "The name of the environment"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the VPC"
}

variable "database_port" {
  type = number
}