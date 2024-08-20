variable "allocated_storage" {
  type = number
}

variable "tags" {
  type = map(string)
}

variable "events_sns_topic" {
  type = string
}

variable "db_parameters" {
  type = object({
    parameter = object({
      name  = string
      value = string
    })
  })

  default = {
    parameter = {
      name  = "time_zone"
      value = "Brazil/East"
    }
  }
}

variable "subnet_group_name" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "ha" {
  type = bool
}

variable "rds_events" {
  type    = list(string)
  default = [""]
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "deletion_protection" {
  type = bool
}

variable "security_groups" {
  type = list(string)
}