project_id = "fresh-84"
region     = "us-central1"
cluster_name = "ai-enterprise"
environment  = "prod"

# Existing VPC
vpc_name            = "prod-vpc"
subnet_name         = "gke-subnet"
pods_range_name     = "pods"
services_range_name = "services"

# Cluster version
kubernetes_version = "1.29"
release_channel    = "REGULAR"

# Private cluster configuration
enable_private_endpoint = true
enable_private_nodes    = true
master_ipv4_cidr_block  = "172.16.0.0/28"

# Authorized networks (bastion, CI/CD, etc.)
master_authorized_networks = [
  {
    cidr_block   = "10.0.0.0/24"
    display_name = "bastion-hosts"
  },
  {
    cidr_block   = "10.1.0.0/24"
    display_name = "github-actions-runners"
  }
]

# Zones for distribution
zones = ["us-central1-a", "us-central1-b", "us-central1-c"]

# Maintenance window
maintenance_config = {
  start_time = "2024-01-01T03:00:00Z"
  end_time   = "2024-01-01T07:00:00Z"
  recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
  exclusions = []
}

# Node Pools - Fully Configurable
node_pools = {
  system = {
    machine_type = "e2-standard-4"
    min_count    = 2
    max_count    = 10
    disk_size_gb = 100
    labels = {
      "node-type" = "system"
      "workload"  = "infrastructure"
    }
    taints = [{
      key    = "dedicated"
      value  = "system"
      effect = "NO_SCHEDULE"
    }]
  }
  
  general = {
    machine_type = "e2-standard-8"
    min_count    = 1
    max_count    = 50
    disk_size_gb = 200
    labels = {
      "node-type" = "general"
      "workload"  = "general"
    }
    taints = []
  }
  
  gpu-training = {
    machine_type = "a2-highgpu-1g"
    min_count    = 0
    max_count    = 10
    disk_size_gb = 500
    zones        = ["us-central1-a"]  # Single zone for GPU consistency
    labels = {
      "node-type" = "gpu"
      "gpu-type"  = "a100"
      "workload"  = "training"
    }
    taints = [
      {
        key    = "nvidia.com/gpu"
        value  = "true"
        effect = "NO_SCHEDULE"
      },
      {
        key    = "dedicated"
        value  = "training"
        effect = "NO_SCHEDULE"
      }
    ]
    guest_accelerators = [{
      type  = "nvidia-tesla-a100"
      count = 1
    }]
  }
  
  gpu-inference = {
    machine_type = "g2-standard-4"
    min_count    = 0
    max_count    = 20
    disk_size_gb = 200
    labels = {
      "node-type" = "gpu"
      "gpu-type"  = "l4"
      "workload"  = "inference"
    }
    taints = [
      {
        key    = "nvidia.com/gpu"
        value  = "true"
        effect = "NO_SCHEDULE"
      },
      {
        key    = "dedicated"
        value  = "inference"
        effect = "NO_SCHEDULE"
      }
    ]
    guest_accelerators = [{
      type  = "nvidia-l4"
      count = 1
    }]
  }
  
  spot-batch = {
    machine_type = "e2-standard-16"
    min_count    = 0
    max_count    = 100
    disk_size_gb = 100
    disk_type    = "pd-standard"
    spot         = true
    labels = {
      "node-type" = "spot"
      "workload"  = "batch"
    }
    taints = [{
      key    = "cloud.google.com/gke-spot"
      value  = "true"
      effect = "NO_SCHEDULE"
    }]
    max_surge       = 5
    max_unavailable = 0
  }
}

# Cluster autoscaling limits
cluster_autoscaling_limits = {
  cpu = {
    minimum = 10
    maximum = 1000
  }
  memory = {
    minimum = 64
    maximum = 4096
  }
  "nvidia-tesla-a100" = {
    minimum = 0
    maximum = 16
  }
  "nvidia-l4" = {
    minimum = 0
    maximum = 32
  }
}

# ArgoCD Configuration
argocd_config = {
  namespace       = "argocd"
  service_account = "argocd-application-controller"
  roles           = ["roles/container.developer", "roles/secretmanager.secretAccessor"]
}

# Additional Workload Identity SAs for AI workloads
workload_identity_service_accounts = {
  ai-training = {
    display_name = "AI Training Workloads"
    description  = "Service account for model training jobs"
    namespace    = "ai-training"
    ksa_name     = "default"
    roles = [
      "roles/storage.objectAdmin",
      "roles/bigquery.user",
      "roles/aiplatform.user"
    ]
  }
  ai-inference = {
    display_name = "AI Inference Workloads"
    description  = "Service account for model serving"
    namespace    = "ai-inference"
    ksa_name     = "inference-sa"
    roles = [
      "roles/storage.objectViewer",
      "roles/monitoring.metricWriter"
    ]
  }
  ml-pipelines = {
    display_name = "ML Pipeline Runner"
    description  = "Service account for Kubeflow/ML pipelines"
    namespace    = "ml-pipelines"
    ksa_name     = "pipeline-runner"
    roles = [
      "roles/storage.objectAdmin",
      "roles/bigquery.dataEditor",
      "roles/aiplatform.admin"
    ]
  }
}

# Observability
enable_managed_prometheus = true
logging_components        = ["SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"]
monitoring_components     = ["SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER", "STORAGE", "HPA", "POD", "DAEMONSET", "DEPLOYMENT", "STATEFULSET"]

# Cost management
enable_cost_allocation    = true
resource_usage_dataset_id = "gke_resource_usage"

# Labels
common_labels = {
  team        = "ml-platform"
  cost-center = "ai-research"
  project     = "enterprise-ai"
}

# Notifications
notification_topics = {
  upgrades = {
    labels = {
      purpose = "cluster-upgrades"
    }
  }
  security = {
    labels = {
      purpose = "security-alerts"
    }
  }
}