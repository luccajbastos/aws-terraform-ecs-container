variable "cluster_name" {
  type        = string
  description = "Name of the Cluster"
}

variable "app_config" {
  type = object({
    region = string
    app_name      = string
    desired_count = number
    app_port      = number
    launch_type   = string
    alb_config = object({
      listener_arn = string
      priority     = number
      hosts        = list(string)
    })
    container_definitions = object({
      image                  = string
      cpu                    = number
      memory                 = number
      essential              = bool
      command                = list(string)
      entryPoint             = list(string)
      readonlyRootFilesystem = bool
      secretsManagerArn      = string
      portMappings = list(object({
        containerPort = number
        hostPort      = number
        protocol      = string
      }))
    })
    network_configuration = object({
      vpc_id           = string
      subnets          = list(string)
      security_groups  = list(string)
      assign_public_ip = bool
    })
    enable_execute_command = bool
  })
}