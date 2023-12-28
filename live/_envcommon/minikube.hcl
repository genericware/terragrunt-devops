locals {
  base_source_url    = "git::git@github.com:generic-infrastructure/terraform-minikube-cluster.git"
  ref                = "feature/baseline-repository"
  name               = "default"
  description        = "A manifest for launching a kubernetes cluster."
  organization       = "generic-infrastructure"
  domain             = "generic-infrastructure.org"
  platform           = "minikube"
  profile            = "default"
  repository         = "https://github.com/generic-infrastructure/app-of-apps.git"
  path               = "."
  branch             = "feature/baseline-repository"
  network_mode       = "istio"
  network_issuer     = "selfsigned"
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
  name               = local.name
  description        = local.description
  organization       = local.organization
  domain             = local.domain
  platform           = local.platform
  profile            = local.profile
  repository         = local.repository
  branch             = local.branch
  path               = local.path
  network_mode       = local.network_mode
  network_issuer     = local.network_issuer
  kubernetes_version = local.kubernetes_version
  nodes              = local.nodes
  cpus               = local.cpus
  memory             = local.memory
  disk_size          = local.disk_size
  extra_disks        = local.extra_disks
}
