variable "project_id" { type = string }
variable "workload_identity_pool" { type = string }

variable "argocd_config" {
  type = object({
    namespace       = string
    service_account = string
    roles           = optional(list(string), ["roles/container.developer"])
  })
  default = null
}

variable "service_accounts" {
  type = map(object({
    display_name = string
    description  = string
    namespace    = string
    ksa_name     = string
    roles        = list(string)
  }))
  default = {}
}