locals {
  base_source_url    = "git::git@github.com:generic-infrastructure/minikube-cluster.git"
  ref                = "feature/package-module"
  name               = "generic-infrastructure"
  description        = "A manifest for launching a kubernetes cluster."
  organization       = "generic-infrastructure"
  domain             = "generic-infrastructure.org"
  profile            = "default"
  repository         = "git@github.com:generic-infrastructure/terragrunt-devops.git"
  branch             = "feature/baseline-project"
  network_mode       = "istio"
  network_issuer     = "selfsigned"
  kubernetes_version = "v1.26.1"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "minikube" {
  kubernetes_version = "${local.kubernetes_version}"
}
provider "local" {}
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
  profile            = local.profile
  repository         = local.repository
  branch             = local.branch
  network_mode       = local.network_mode
  network_issuer     = local.network_issuer
  kubernetes_version = local.kubernetes_version
  nodes              = 4
  cpus               = 4
  memory             = 8192
  disk_size          = 25600
  extra_disks        = 0
}
