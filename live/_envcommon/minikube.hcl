locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  base_source_url  = "git::git@github.com:generic-infrastructure/minikube-cluster.git"
  ref              = "feature/package-module"
}

# todo: param version
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "minikube" {
  kubernetes_version = "v1.26.1"
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
    if_exists = "overwrite"
  }
}

inputs = {
  nodes       = 4
  cpus        = 4
  memory      = 8192
  disk_size   = 25600
  extra_disks = 0
}
