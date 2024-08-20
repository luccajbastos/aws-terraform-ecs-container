output "db_topic_arn" {
  value = aws_sns_topic.db_events.arn
}