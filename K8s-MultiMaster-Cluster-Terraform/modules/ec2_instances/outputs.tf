output "master_ips" {
  value = [for instance in aws_instance.masters : instance.public_ip]
}

output "worker_ips" {
  value = [for instance in aws_instance.workers : instance.public_ip]
}

output "master_ids" {
  value = [for instance in aws_instance.masters : instance.id]
}

output "worker_ids" {
  value = [for instance in aws_instance.workers : instance.id]
}

output "user_data" {
  value       = [for instance in aws_instance.workers : instance.user_data]
  description = "The user data script used for EC2 instances"
}
