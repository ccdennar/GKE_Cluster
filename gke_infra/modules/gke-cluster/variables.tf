variable "project_id" { type = string }
variable "region" { type = string }
variable "cluster_name" { type = string }
variable "vpc_name" { type = string }
variable "subnet_name" { type = string }
variable "pods_range_name" { type = string }
variable "services_range_name" { type = string }
variable "kubernetes_version" { type = string }
variable "release_channel" { type = string }
variable "enable_private_endpoint" { type = bool }
variable "enable_private_nodes" { type = bool }
variable "master_ipv4_cidr_block" { type = string }
variable "master_authorized_networks" { 
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}
variable "dns_access_scope" { 
  type    = string 
  default = "VPC_SCOPE" 
}

variable "create_nat" {
  type    = bool
  default = false
}

variable "maintenance_config" {
  type = object({
    start_time = string
    end_time   = string
    recurrence = string
    exclusions = optional(list(object({
      name            = string
      start_time      = string
      end_time        = string
      exclusion_scope = optional(string, "NO_UPGRADES")
    })), [])
  })
}

variable "enable_managed_prometheus" { type = bool }
variable "logging_components" { type = list(string) }
variable "monitoring_components" { type = list(string) }
variable "binary_authorization_mode" { type = string }
variable "enable_cost_allocation" { type = bool }
variable "resource_usage_dataset_id" { 
  type    = string
  default = null
}

variable "cluster_autoscaling_limits" {
  type = map(object({
    minimum = number
    maximum = number
  }))
  default = {}
}

variable "cluster_labels" {
  type    = map(string)
  default = {}
}

variable "notification_topics" {
  type = map(object({
    labels = optional(map(string), {})
  }))
  default = {}
}

variable "location" {
  description = "Zone for zonal cluster or region for regional cluster"
  type        = string
  default     = null
}

variable "nat_config" {
  description = "Cloud NAT configuration when NAT creation is enabled"
  type = object({
    min_ports_per_vm = number
    log_filter       = string
    nat_regions      = optional(list(string), null)  # null uses cluster region
    
  })
  default = {
    min_ports_per_vm = 128
    log_filter       = "ALL"
    nat_regions      = ["us-central1", "us-east1"]
  }
}