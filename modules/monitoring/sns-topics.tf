resource "aws_sns_topic" "db_events" {
  name = "rds-events"
}