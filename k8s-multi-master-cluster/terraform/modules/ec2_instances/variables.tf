variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 KeyPair to enable SSH access"
  type        = string
}

variable "security_groups_ids" {
  description = "Security group ID"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "num_masters" {
  description = "Number of master nodes"
  type        = number
}

variable "num_workers" {
  description = "Number of worker nodes"
  type        = number
}

variable "CONTAINERD_VERSION" {
  description = "Containerd version"
  type        = string
  default     = "1.7.20"
}
