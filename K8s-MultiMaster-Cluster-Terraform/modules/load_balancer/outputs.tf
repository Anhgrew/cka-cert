output "load_balancer_dns" {
  value       = aws_lb.k8s_alb.dns_name
  description = "Value of load balancer dns"
}
