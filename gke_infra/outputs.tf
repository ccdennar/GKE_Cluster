# Cluster Core Information
output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = module.gke_cluster.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The CA certificate of the GKE cluster (base64 encoded)"
  value       = module.gke_cluster.cluster_ca_certificate
  sensitive   = true
}

output "cluster_id" {
  description = "The ID of the GKE cluster"
  value       = module.gke_cluster.cluster_id
}

output "cluster_location" {
  description = "The location (region) of the GKE cluster"
  value       = var.region
}

# Workload Identity
output "workload_identity_pool" {
  description = "The Workload Identity pool for the cluster"
  value       = module.gke_cluster.workload_identity_pool
}

output "node_service_account_email" {
  description = "The email of the GKE node service account"
  value       = module.gke_cluster.node_service_account_email
}

# Workload Identity Service Accounts
output "workload_identity_service_accounts" {
  description = "Map of Workload Identity service account emails"
  value       = module.workload_identity.service_account_emails
}

output "argocd_service_account_email" {
  description = "The GCP service account email for ArgoCD (if configured)"
  value       = var.argocd_config != null ? module.workload_identity.service_account_emails["argocd"] : null
}

# Node Pools
output "node_pool_names" {
  description = "Map of node pool names"
  value       = module.node_pools.node_pool_names
}

output "node_pool_ids" {
  description = "Map of node pool IDs"
  value       = module.node_pools.node_pool_ids
}

# Kubernetes Connection
output "gcloud_connect_command" {
  description = "gcloud command to connect to the cluster"
  value       = "gcloud container clusters get-credentials ${module.gke_cluster.cluster_name} --region=${var.region} --project=${var.project_id}"
}

output "kubectl_context" {
  description = "Kubectl context name for this cluster"
  value       = "gke_${var.project_id}_${var.region}_${module.gke_cluster.cluster_name}"
}

# Networking
output "network_name" {
  description = "The VPC network name"
  value       = var.vpc_name
}

output "subnet_name" {
  description = "The subnet name"
  value       = var.subnet_name
}

output "master_ipv4_cidr_block" {
  description = "The CIDR block for the master endpoint"
  value       = var.enable_private_nodes ? var.master_ipv4_cidr_block : null
}

# Namespaces
# output "created_namespaces" {
#   description = "List of namespaces created for Workload Identity"
#   value       = [for ns in kubernetes_namespace.workloads : ns.metadata[0].name]
# }

# Notification Topics
output "notification_topic_ids" {
  description = "Map of notification Pub/Sub topic IDs"
  value       = module.gke_cluster.notification_topic_ids
}

# Security
output "private_cluster_enabled" {
  description = "Whether private cluster is enabled"
  value       = var.enable_private_nodes
}

output "private_endpoint_enabled" {
  description = "Whether private endpoint is enabled"
  value       = var.enable_private_endpoint
}

# Maintenance
output "maintenance_window" {
  description = "The configured maintenance window"
  value = {
    start_time = var.maintenance_config.start_time
    end_time   = var.maintenance_config.end_time
    recurrence = var.maintenance_config.recurrence
  }
}

# Cost and Labels
output "cluster_labels" {
  description = "Labels applied to the cluster"
  value       = local.cluster_labels
}

output "cost_allocation_enabled" {
  description = "Whether cost allocation is enabled"
  value       = var.enable_cost_allocation
}

# ArgoCD Configuration
output "argocd_namespace" {
  description = "The namespace for ArgoCD (if configured)"
  value       = var.argocd_config != null ? var.argocd_config.namespace : null
}

output "argocd_ksa_annotation" {
  description = "The annotation to apply to ArgoCD KSA for Workload Identity"
  value       = var.argocd_config != null ? "iam.gke.io/gcp-service-account=${module.workload_identity.service_account_emails["argocd"]}" : null
}

# Full Connection Info (for automation)
output "cluster_connection_info" {
  description = "Complete connection information for CI/CD automation"
  value = {
    endpoint           = module.gke_cluster.cluster_endpoint
    ca_certificate     = module.gke_cluster.cluster_ca_certificate
    name               = module.gke_cluster.cluster_name
    location           = var.region
    project            = var.project_id
    workload_identity_pool = module.gke_cluster.workload_identity_pool
  }
  sensitive = true
}

# Environment Info
output "environment" {
  description = "The environment label"
  value       = var.environment
}

output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}