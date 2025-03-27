// Configure the LitmusChaos provider
provider "litmuschaos" {
  // Use the load balancer endpoint created for the LKE cluster
  host  = "http://${kubernetes_service.litmus_frontend.status.load_balancer.ingress[0].ip}:9091" // LitmusChaos Center URL
  token = data.kubernetes_secret.litmus_token.data.token                                         // Dynamically generated token
}
