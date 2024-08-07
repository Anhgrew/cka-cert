variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-05fa140f427e931bf"
}

variable "alb_name" {
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
  default     = ["subnet-0c95c842727df71de", "subnet-0bbdaf704d4abfc2a"]
}

variable "num_masters" {
  description = "Number of master nodes"
  type        = number
  default     = 2
}

variable "num_workers" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-009c9406091cbd65a"
}




variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.small"
}



variable "key_name" {
  description = "Key name"
  type        = string
  default     = "anhdrew"
}

variable "security_group_name" {
  description = "Security group name"
  type        = string
  default     = "k8s-sg"
}

variable "security_group_description" {
  description = "Security group description"
  type        = string
  default     = "Kubernetes security group"
}
