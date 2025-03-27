// Define the required providers
terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.7.1" // Linode provider version
    }
    litmuschaos = {
      source  = "williamokano/litmus-chaos"
      version = "0.2.0" // LitmusChaos provider version
    }
  }
}

// Configure the Linode provider with the API token
provider "linode" {
  token = var.token // Linode API token
}

// Write the kubeconfig to a file
resource "local_file" "kubeconfig" {
  filename = "${path.module}/tallerlitmus-lke-cluster-kubeconfig.yaml" // Path to save the kubeconfig file
  content  = linode_lke_cluster.tallerlitmus.kubeconfig               // Kubeconfig content from the Linode LKE cluster
}

// Configure the Kubernetes provider to use the kubeconfig file
provider "kubernetes" {
  config_path = local_file.kubeconfig.filename // Use the path of the generated kubeconfig file
}

// Create a Kubernetes cluster using Linode LKE
resource "linode_lke_cluster" "tallerlitmus" {
  k8s_version = var.k8s_version // Kubernetes version
  label       = var.label       // Cluster label
  region      = var.region      // Region for the cluster
  tags        = var.tags        // Tags for the cluster

  // Dynamically create node pools based on the provided configuration
  dynamic "pool" {
    for_each = var.pools
    content {
      type  = pool.value["type"]  // Node type
      count = pool.value["count"] // Number of nodes
    }
  }

  // Add a new node pool for the "db" workload
  pool {
    type  = "g6-standard-2" // Node type for the "db" pool
    count = 1               // Number of nodes in the "db" pool
  }
}

// Create a Linode instance to act as a proxy
resource "linode_instance" "proxy" {
  label      = "${var.label}-proxy" // Label for the proxy instance
  region     = var.region           // Region for the proxy instance
  type       = "g6-nanode-1"        // Lightweight instance type
  image      = "linode/ubuntu22.04" // Use Ubuntu 22.04
  root_pass  = var.root_password    // Root password for the instance
  private_ip = true                 // Enable private IP for the instance

  // SSH connection details for provisioning
  connection {
    type     = "ssh"             // Use SSH for provisioning
    user     = "root"            // SSH user
    password = var.root_password // SSH password
    host     = tolist(linode_instance.proxy.ipv4)[1] // Explicitly use the public IP
    timeout  = "10m"                                 // Increase timeout to allow for instance boot
  }

  // Step 1: Upload the provisioning script to the instance
  provisioner "file" {
    source      = "${path.module}/nginx_provision.sh" // Path to the provisioning script
    destination = "/tmp/nginx_provision.sh"           // Destination on the instance
  }

  // Step 2: Execute the provisioning script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx_provision.sh",                                                    // Make the script executable
      "/tmp/nginx_provision.sh ${element(linode_lke_cluster.tallerlitmus.api_endpoints, 0)}" // Execute the script
    ]
  }

  // Log the public IP for debugging
  provisioner "local-exec" {
    command = "echo 'Public IP: ${tolist(self.ipv4)[1]}'"
  }
}

// Outputs for debugging and usage
output "proxy_public_ip" {
  value       = tolist(linode_instance.proxy.ipv4)[1] // Public IP of the proxy instance
  description = "The public IP address of the proxy instance"
}

output "proxy_private_ip" {
  value       = tolist(linode_instance.proxy.ipv4)[0] // Private IP of the instance
  description = "The private IP address of the proxy instance"
}

output "proxy_ipv4_debug" {
  value       = tolist(linode_instance.proxy.ipv4) // List of IPv4 addresses
  description = "Debug: The list of IPv4 addresses assigned to the proxy instance"
}

output "kubeconfig_path" {
  value       = local_file.kubeconfig.filename // Path to the kubeconfig file
  description = "The path to the kubeconfig file used by the Kubernetes provider"
}

output "api_endpoints" {
  value       = linode_lke_cluster.tallerlitmus.api_endpoints // API endpoints of the cluster
  description = "The API endpoints of the Kubernetes cluster"
}

output "status" {
  value = linode_lke_cluster.tallerlitmus.status // Status of the cluster
}

output "id" {
  value = linode_lke_cluster.tallerlitmus.id // ID of the cluster
}

output "pool" {
  value = linode_lke_cluster.tallerlitmus.pool // Node pool details
}