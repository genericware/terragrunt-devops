locals {
  base_source_url    = "git::git@github.com:generic-infrastructure/terraform-minikube-cluster.git"
  ref                = "feature/patches-1"
  kubernetes_version = "v1.28.3"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "minikube" {
  kubernetes_version = "${local.kubernetes_version}"
}
provider "kubernetes" {
  host                   = minikube_cluster.default.host
  client_certificate     = minikube_cluster.default.client_certificate
  client_key             = minikube_cluster.default.client_key
  cluster_ca_certificate = minikube_cluster.default.cluster_ca_certificate
}
EOF
}

remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {}
