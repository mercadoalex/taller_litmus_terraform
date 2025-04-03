# Add the environment variable
label       = "dev-lke-cluster"
k8s_version = "1.32"    # Ensure this version is correct
region      = "us-west" #US, Fremont, CA
environment = "dev"
pools = [
  {
    type  = "g6-standard-2"
    count = 2
    tags = {
      environment = "desarrollo"
      author      = "alex"
      cloud       = "akamai"
    }
  },
  {
    type  = "g6-standard-1"
    count = 1
    tags = {
      environment = "desarrollo"
      author      = "alex"
      cloud       = "akamai"
    }
  }
]
kubeconfig_file = "dev-lke-cluster-dev-kubeconfig.yaml"
datadog_api_key = "dsadas"         # Datadog API key
datadog_app_key = "0dsa" # Datadog application key
db_pv           = "db-pv-dev"

