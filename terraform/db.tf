# Create a Linode Block Storage Volume
resource "linode_volume" "db_volume" {
  label  = "db-volume"       # Name of the volume
  size   = 20                # Size in GB
  region = var.region        # Region (must match your Kubernetes cluster region)
}

# Create a Persistent Volume (PV) for the Block Storage
resource "kubernetes_persistent_volume" "db_pv" {
  metadata {
    name = "db-pv" # Name of the Persistent Volume
  }

  spec {
    capacity = {
      storage = "20Gi" # Match the size of the Linode Block Storage Volume
    }

    access_modes = ["ReadWriteOnce"] # Allow one pod to write to the volume

    persistent_volume_source {
      flex_volume {
        driver  = "linode/linode-blockstorage"
        options = {
          volumeID = linode_volume.db_volume.id # Reference the Linode Block Storage Volume
        }
      }
    }
  }

  # Prevent the PV from being destroyed
  lifecycle {
    prevent_destroy = true
  }
}

# Create a Persistent Volume Claim (PVC)
resource "kubernetes_persistent_volume_claim" "db_pvc" {
  metadata {
    name      = "db-pvc"  # Name of the Persistent Volume Claim
    namespace = "default" # Namespace for the PVC
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "20Gi" # Match the size of the Persistent Volume
      }
    }
  }

  # Prevent the PVC from being destroyed
  lifecycle {
    prevent_destroy = true
  }
}

# Deploy a PostgreSQL container with persistent storage
resource "kubernetes_pod" "db_pod" {
  metadata {
    name      = "db"                              # Name of the pod
    namespace = "default"                         # Namespace to deploy the pod
    labels = {
      app = "db"                                  # Label for the pod
    }
  }

  spec {
    container {
      name  = "db"                                # Name of the container
      image = "postgres:15"                       # Docker image for PostgreSQL

      # Define environment variables for PostgreSQL configuration
      env {
        name  = "POSTGRES_USER"                   # PostgreSQL username
        value = "odoo"
      }

      env {
        name  = "POSTGRES_PASSWORD"              # PostgreSQL password
        value = "odoo"
      }

      env {
        name  = "POSTGRES_DB"                    # PostgreSQL database name
        value = "postgres"
      }

      # Mount the Persistent Volume Claim to the container
      volume_mount {
        name       = "db-storage"                 # Name of the volume mount
        mount_path = "/var/lib/postgresql/data"   # Path inside the container where data will be stored
      }

      # Define the port exposed by the container
      port {
        container_port = 5432                     # PostgreSQL default port
        name           = "postgresql"             # Optional: Name of the port
        protocol       = "TCP"                    # Protocol (default is TCP)
      }
    }

    # Define the volume for the pod
    volume {
      name = "db-storage"                         # Name of the volume
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.db_pvc.metadata[0].name # Reference the PVC
      }
    }
  }
}

# Outputs for debugging and verification
output "linode_volume_id" {
  value       = linode_volume.db_volume.id
  description = "The ID of the Linode Block Storage Volume"
}

output "persistent_volume_name" {
  value       = kubernetes_persistent_volume.db_pv.metadata[0].name
  description = "The name of the Persistent Volume created for the PostgreSQL pod"
}

output "persistent_volume_claim_name" {
  value       = kubernetes_persistent_volume_claim.db_pvc.metadata[0].name
  description = "The name of the Persistent Volume Claim used by the PostgreSQL pod"
}

output "postgresql_pod_name" {
  value       = kubernetes_pod.db_pod.metadata[0].name
  description = "The name of the PostgreSQL pod"
}