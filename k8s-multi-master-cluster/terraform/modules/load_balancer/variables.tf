variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-05fa140f427e931bf"
}

variable "security_groups_ids" {
  description = "Security group ID"
  type        = list(string)
}

variable "name" {
  description = "Name of the load balancer"
  type        = string
  default     = "k8s-alb"
}

variable "type" {
  description = "Type of the load balancer"
  type        = string
  default     = "network"

}
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "master_ids" {
  description = "List of master instances ids"
  type        = list(string)
}
