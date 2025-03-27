label       = "tallerlitmus-lke-cluster"
k8s_version = "1.31" # Ensure this version is correct
region      = "us-west"
/*pools = [
  {
    type : "g6-standard-2"
    count : 3
  }
]*/
pools = [
  {
    type  = "g6-standard-2"
    count = 2
  },
  {
    type  = "g6-standard-1"
    count = 1
  }
]