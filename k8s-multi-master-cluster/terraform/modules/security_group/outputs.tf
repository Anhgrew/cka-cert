output "security_group_id" {
  value       = aws_security_group.k8s_sg.id
  description = "Value of security group id"
}
