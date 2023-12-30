locals {
  base_source_url    = "git::git@github.com:generic-infrastructure/terraform-gke-cluster.git"
  ref                = "feature/baseline-repository"
  kubernetes_version = ""  # todo
}

# todo
generate "providers" {}

# todo
remote_state {}

# todo
inputs = {}
