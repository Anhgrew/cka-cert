variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-05fa140f427e931bf"
}

variable "name" {
  description = "Security group name"
  type        = string
  default     = "k8s-sg"
}

variable "description" {
  description = "Security group description"
  type        = string
  default     = "Kubernetes security group"
}

