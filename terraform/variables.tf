# Environment Variable
variable "environment" {
  description = "The environment for the Kubernetes cluster (e.g., demo, staging, production)."
  type        = string
  default     = "dev" # Default value
}
variable "kubeconfig_file" {
  description = "Path to the kubeconfig file for the Kubernetes cluster"
  type        = string
  default     = "dev-lke-cluster-demo-kubeconfig.yaml"
}

variable "token" {
  description = "Your Linode API Personal Access Token. (required)"
  type        = string
  default     = "d03ab8333e1c304756e0f6fbe0b9a38b20dd538c4a6ab85af23770829d761acd"
}

variable "k8s_version" {
  description = "The Kubernetes version to use for this cluster. (required)"
  default     = "1.31"
}
# Cluster Label
variable "label" {
  description = "The unique label to assign to this cluster. (required)"
  default     = "dev-lke-cluster"
}

variable "region" {
  description = "The region where your cluster will be located. (required)"
  default     = "us-east"
}

variable "tags" {
  description = "Tags to apply to your cluster for organizational purposes. (optional)"
  type        = list(string)
  default     = ["litmus", "akamai", "alex"]
}

variable "pools" {
  description = "The Node Pool specifications for the Kubernetes cluster. (required)"
  type = list(object({
    type  = string
    count = number
    tags  = map(string) # Add a map for tags

  }))
  default = [
    {
      type  = "g6-standard-4"
      count = 3
      tags = {
        author = "Alex"
        cloud  = "akamai"
      }
    },
    {
      type  = "g6-standard-8"
      count = 3
      tags = {
        author = "Alex"
        cloud  = "akamai"
      }
    }
  ]
}
# Root Password for Linode Instances
variable "root_password" {
  description = "The root password for the Linode instance. (required)"
  type        = string
  default     = "TallerLitmus@2025!" // A secure and valid default password
}
variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
}

variable "datadog_app_key" {
  description = "Datadog application key"
  type        = string
}
# List of Kubernetes Worker Node IPs
variable "worker_nodes" {
  description = "A list of IP addresses for the Kubernetes worker nodes."
  type        = list(string)
  default     = [] # Replace with actual IPs or leave empty to provide dynamically
}
variable "db_pv" {
  description = "The name of the Persistent Volume for the database."
  type        = string
  default     = "db-pv-dev" // Persistent Volume
}