// Configure the Datadog provider with the API and application keys
provider "datadog" {
  api_key = var.datadog_api_key             // Datadog API key
  app_key = var.datadog_app_key             // Datadog application key
  api_url = "https://api.us5.datadoghq.com" // For US5 region
}

// Add the Datadog agent to the Linode proxy instance
resource "null_resource" "install_datadog_agent_proxy" {
  depends_on = [linode_instance.proxy] // Ensure the Linode proxy instance is created before installing the agent

  provisioner "remote-exec" {
    connection {
      type     = "ssh"                                 // Use SSH for provisioning
      user     = "root"                                // SSH user
      password = var.root_password                     // SSH password
      host     = tolist(linode_instance.proxy.ipv4)[1] // Use the public IP of the proxy instance
    }

    inline = [
      // Install the Datadog agent using the official installation script
      "DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${var.datadog_api_key} DD_SITE='datadoghq.com' bash -c \"$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)\""
    ]
  }
}

// Add the Datadog agent to each Kubernetes worker node
resource "null_resource" "install_datadog_agent_workers" {
  for_each = toset(var.worker_nodes) // Iterate over the list of worker node IPs

  provisioner "remote-exec" {
    connection {
      type     = "ssh"             // Use SSH for provisioning
      user     = "root"            // SSH user
      password = var.root_password // SSH password
      host     = each.key          // Use the IP address of the worker node
    }

    inline = [
      // Install the Datadog agent using the official installation script
      "DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${var.datadog_api_key} DD_SITE='datadoghq.com' bash -c \"$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)\""
    ]
  }
}

// Create a Datadog dashboard for monitoring Kubernetes and Linode resources
resource "datadog_dashboard" "k8s_dashboard" {
  title       = "Kubernetes Cluster Dashboard on ${var.environment}" // Title of the dashboard
  description = "Dashboard for monitoring the Kubernetes cluster and Linode resources"
  layout_type = "ordered" // Layout type for the dashboard

  // Widget to monitor Kubernetes node CPU usage
  widget {
    timeseries_definition {
      title = "Kubernetes Nodes CPU Usage" // Title of the widget
      request {
        q            = "avg:kubernetes.cpu.usage.total{*} by {node}" // Query for node CPU usage
        display_type = "line"                                        // Display as a line graph
      }
    }
  }

  // Widget to monitor Kubernetes pod memory usage
  widget {
    timeseries_definition {
      title = "Kubernetes Pods Memory Usage" // Title of the widget
      request {
        q            = "avg:kubernetes.memory.usage{*} by {pod_name}" // Query for pod memory usage
        display_type = "line"                                         // Display as a line graph
      }
    }
  }

  // Widget to monitor Linode proxy CPU usage
  widget {
    timeseries_definition {
      title = "Linode Proxy CPU Usage" // Title of the widget
      request {
        q            = "avg:system.cpu.user{host:${tolist(linode_instance.proxy.ipv4)[1]}}" // Query for proxy CPU usage
        display_type = "line"                                                               // Display as a line graph
      }
    }
  }
}
output "datadog_dashboard_id" {
  value = datadog_dashboard.k8s_dashboard.id
}