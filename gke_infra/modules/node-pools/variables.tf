variable "cluster_name" { type = string }
variable "cluster_id" { type = string }
variable "region" { type = string }
variable "zones" { type = list(string) }
variable "node_service_account" { type = string }

variable "node_pools" {
  type = map(object({
    machine_type       = string
    min_count          = number
    max_count          = number
    disk_size_gb       = optional(number, 100)
    disk_type          = optional(string, "pd-ssd")
    spot               = optional(bool, false)
    taints             = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    labels             = optional(map(string), {})
    guest_accelerators = optional(list(object({
      type  = string
      count = number
    })), [])
    zones              = optional(list(string), null)
    auto_repair        = optional(bool, true)
    auto_upgrade       = optional(bool, true)
    max_surge          = optional(number, 1)
    max_unavailable    = optional(number, 0)
    secure_boot        = optional(bool, true)
    integrity_monitoring = optional(bool, true)
  }))
}