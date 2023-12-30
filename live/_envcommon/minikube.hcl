locals {
  base_source_url    = "git::git@github.com:generic-infrastructure/terraform-minikube-cluster.git"
  ref                = "feature/baseline-repository"
  kubernetes_version = "v1.26.1"
  nodes              = 4
  cpus               = 5
  memory             = 8192
  disk_size          = 25600
  extra_disks        = 0
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  host                   = minikube_cluster.default.host
  client_certificate     = minikube_cluster.default.client_certificate
  client_key             = minikube_cluster.default.client_key
  cluster_ca_certificate = minikube_cluster.default.cluster_ca_certificate
}
provider "local" {}
provider "minikube" {
  kubernetes_version = "${local.kubernetes_version}"
}
EOF
}

remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  nodes       = local.nodes
  cpus        = local.cpus
  memory      = local.memory
  disk_size   = local.disk_size
  extra_disks = local.extra_disks
}
