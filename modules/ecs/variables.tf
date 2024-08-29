variable "ecs_cluster_settings" {
  type = object({
    name              = string
    containerInsights = bool
    kms_key_arn       = string
  })

  default = {
    name              = null
    containerInsights = null
    kms_key_arn       = null
  }
}

variable "tags" {
  type = map(string)
}