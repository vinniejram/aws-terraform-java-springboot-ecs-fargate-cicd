variable "name" {
  default = "cargarage-ecs"
}

variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "1"
}

variable "redis_cluster_count" {
  description = "to enable/disable redis since creation is slow"
  default     = 1
}

