output "security_group_id" {
  description = "The ID of the security group"
  value       = module.security_group.security_group_id
}

output "master_ips" {
  description = "The public IP addresses of the master nodes"
  value       = module.ec2_instances.master_ips
}

output "worker_ips" {
  description = "The public IP addresses of the worker nodes"
  value       = module.ec2_instances.worker_ips
}

# Load Balancer outputs
output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = module.load_balancer.load_balancer_dns
}

output "ec2_user_data" {
  value       = module.ec2_instances.user_data
  description = "The user data script used for EC2 instances"
}
