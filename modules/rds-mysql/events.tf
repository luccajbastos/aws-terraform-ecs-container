locals {
  rds_default_events = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "maintenance",
    "notification",
    "read replica",
    "recovery",
    "restoration"
  ]
}

resource "aws_db_event_subscription" "rds_events" {
  name      = "${local.name}-events"
  sns_topic = var.events_sns_topic

  source_type = "db-instance"
  source_ids  = [aws_db_instance.rdsmysql.identifier]

  event_categories = var.rds_events != "" ? var.rds_events : local.rds_default_events
}