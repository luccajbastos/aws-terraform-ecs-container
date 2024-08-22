output "alb_https_listener_arn" {
  value = aws_lb_listener.https_listener.*.arn
}

output "alb_http_listener_arn" {
  value = aws_lb_listener.http_listener.*.arn 
}

output "alb_endpoint" {
  value = aws_lb.alb.dns_name
}