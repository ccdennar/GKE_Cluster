locals {
  # Merge ArgoCD config with other service accounts if provided
  all_service_accounts = merge(
    var.argocd_config != null ? {
      argocd = {
        display_name = "ArgoCD Application Controller"
        description  = "Service account for ArgoCD GitOps"
        namespace    = var.argocd_config.namespace
        ksa_name     = var.argocd_config.service_account
        roles        = var.argocd_config.roles
      }
    } : {},
    var.service_accounts
  )
}

# Create GCP Service Accounts dynamically
resource "google_service_account" "workloads" {
  for_each = local.all_service_accounts
  
  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
}

# Workload Identity bindings for each SA
resource "google_service_account_iam_member" "workload_identity" {
  for_each = local.all_service_accounts
  
  service_account_id = google_service_account.workloads[each.key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.workload_identity_pool}[${each.value.namespace}/${each.value.ksa_name}]"
}

# Dynamic IAM role bindings for each service account
locals {
  # Flatten role assignments for dynamic binding
  role_bindings = flatten([
    for sa_key, sa in local.all_service_accounts : [
      for role in sa.roles : {
        key       = "${sa_key}-${replace(role, "/", "-")}"
        sa_email  = google_service_account.workloads[sa_key].email
        role      = role
      }
    ]
  ])
}

resource "google_project_iam_member" "workload_roles" {
  for_each = { for binding in local.role_bindings : binding.key => binding }
  
  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.sa_email}"
}