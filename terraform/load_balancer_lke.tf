// Configure the NodeBalancer
resource "linode_nodebalancer" "tallerlitmus_lb" {
  label  = "${var.label}-lb" // Label for the NodeBalancer
  region = var.region        // Region for the NodeBalancer
}

// Configure the NodeBalancer's configuration
resource "linode_nodebalancer_config" "tallerlitmus_lb_config" {
  nodebalancer_id = linode_nodebalancer.tallerlitmus_lb.id // NodeBalancer ID
  port            = 6443                                   // Port to listen on
  protocol        = "tcp"                                  // Protocol to use (TCP for Kubernetes API)
  algorithm       = "roundrobin"                           // Load balancing algorithm
}

// Add nodes to the NodeBalancer
resource "linode_nodebalancer_node" "tallerlitmus_lb_node" {
  for_each        = toset(["proxy-1"])                                   // Dynamically create nodes (e.g., for Kubernetes worker nodes)
  nodebalancer_id = linode_nodebalancer.tallerlitmus_lb.id               // NodeBalancer ID
  config_id       = linode_nodebalancer_config.tallerlitmus_lb_config.id // NodeBalancer configuration ID
  address         = "${tolist(linode_instance.proxy.ipv4)[0]}:6443"      // Use the private IP with the required port
  label           = substr("${var.label}-node-${each.key}", 0, 32)       // Ensure label is within 3-32 characters
  mode            = "accept"                                             // Node mode
  weight          = 100                                                  // Node weight

  depends_on = [linode_instance.proxy] // Ensure the proxy instance is created first
}

// Outputs for debugging and usage
output "load_balancer_endpoint" {
  value       = linode_nodebalancer.tallerlitmus_lb.ipv4 // Public IPv4 address of the NodeBalancer
  description = "The public IPv4 address of the load balancer"
}

output "nodebalancer_address_debug" {
  value       = "${linode_nodebalancer.tallerlitmus_lb.ipv4}:6443" // NodeBalancer public IP with port
  description = "The address being used for the NodeBalancer node"
}
