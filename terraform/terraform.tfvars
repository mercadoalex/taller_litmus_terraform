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
datadog_api_key = "a2321a4ea8941efbdcab2fa897e6bfa3"         # Datadog API key
datadog_app_key = "061cce7ef5ca0237ecefe54811787b098205ab85" # Datadog application key
db_pv           = "db-pv-dev"

