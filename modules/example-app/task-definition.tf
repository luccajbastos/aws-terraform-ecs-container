data "aws_secretsmanager_secret" "container_secrets" {
  arn = var.app_config.container_definitions.secretsManagerArn
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.container_secrets.id
}

locals {
  secrets = [
    for n, v in jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string)) : 
    {
      name      = n
      valueFrom = "${var.app_config.container_definitions.secretsManagerArn}:${v}::"
    }
  ]
}


resource "aws_ecs_task_definition" "this" {
  family = "${local.service_name}-task-definition"
  task_role_arn = aws_iam_role.container_role.arn
  execution_role_arn = aws_iam_role.container_role.arn
  cpu                    = var.app_config.container_definitions.cpu
  memory                 = var.app_config.container_definitions.memory
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group = "true"
          awslogs-group         = "log-${local.container_name}"
          awslogs-region        = var.app_config.region
          awslogs-stream-prefix = local.service_name
        }
      }
      name                   = local.container_name
      image                  = var.app_config.container_definitions.image
      essential              = var.app_config.container_definitions.essential
      portMappings           = var.app_config.container_definitions.portMappings
      command                = var.app_config.container_definitions.command
      entryPoint             = var.app_config.container_definitions.entryPoint
      readonlyRootFilesystem = var.app_config.container_definitions.readonlyRootFilesystem
      secrets                 = local.secrets
    }
  ])

}