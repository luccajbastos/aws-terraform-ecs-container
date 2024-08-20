variable "name" {
  type = string
}
variable "tags" {
  type = map(string)
}
variable "performance_mode" {
  type    = string
  default = "generalPurpose"
}
variable "subnets" {
  type = list(string)
}

variable "security_groups_ids" {
  type = list(string)
}