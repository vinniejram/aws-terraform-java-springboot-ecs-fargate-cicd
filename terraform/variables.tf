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

######
# Event Bridge
######

variable "bus_name" {
  description = "A unique name for your EventBridge Bus"
  type        = string
  default     = "default"
}

variable "rules" {
  description = "A map of objects with EventBridge Rule definitions."
  type        = map(any)
  default     = {}
}

variable "targets" {
  description = "A map of objects with EventBridge Target definitions."
  type        = any
  default     = {}
}

variable "archives" {
  description = "A map of objects with the EventBridge Archive definitions."
  type        = map(any)
  default     = {}
}

variable "permissions" {
  description = "A map of objects with EventBridge Permission definitions."
  type        = map(any)
  default     = {}
}

variable "connections" {
  description = "A map of objects with EventBridge Connection definitions."
  type        = any
  default     = {}
}

variable "api_destinations" {
  description = "A map of objects with EventBridge Destination definitions."
  type        = map(any)
  default     = {}
}
