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
  default     = "default-lke-cluster"
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
  }))
  default = [
    {
      type  = "g6-standard-4"
      count = 3
    },
    {
      type  = "g6-standard-8"
      count = 3
    }
  ]
}
# Root Password for Linode Instances
variable "root_password" {
  description = "The root password for the Linode instance. (required)"
  type        = string
  default     = "TallerLitmus@2025!" // A secure and valid default password
}