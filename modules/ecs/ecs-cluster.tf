locals {
  name = "${var.ecs_cluster_settings.name}-cluster"
  tags = var.tags

  enable_container_insights = var.ecs_cluster_settings.containerInsights ? "enabled" : "disabled"
  enable_encryption         = var.ecs_cluster_settings.kms_key_arn != "" ? var.ecs_cluster_settings.kms_key_arn : null
}

resource "aws_ecs_cluster" "this" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = local.enable_container_insights
  }

  configuration {
    execute_command_configuration {
      kms_key_id = local.enable_encryption
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.cluster_log_group.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "cluster_log_group" {
  name              = "${local.name}-log"
  retention_in_days = 7

  tags = local.tags
}