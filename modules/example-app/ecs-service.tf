locals {
  service_name   = "${var.app_config.app_name}-svc"
  container_name = "${var.app_config.app_name}-pod"
}

resource "aws_lb_target_group" "this" {
  name     = "${local.service_name}-tg"
  port     = var.app_config.app_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.app_config.network_configuration.vpc_id
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.app_config.alb_config.listener_arn
  priority     = var.app_config.alb_config.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }

  condition {
    host_header {
      values = var.app_config.alb_config.hosts
    }
  }
}

resource "aws_ecs_service" "this" {
  name                    = local.service_name
  cluster                 = var.cluster_name
  task_definition         = aws_ecs_task_definition.this.arn
  desired_count           = var.app_config.desired_count
  launch_type           = "FARGATE"
  enable_ecs_managed_tags = true

  enable_execute_command  = var.app_config.enable_execute_command

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = local.container_name
    container_port   = var.app_config.app_port
  }

  network_configuration {
    subnets          = var.app_config.network_configuration.subnets
    security_groups  = var.app_config.network_configuration.security_groups
    assign_public_ip = var.app_config.network_configuration.assign_public_ip
  }

}