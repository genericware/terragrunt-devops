locals {
  base_source_url    = "git::git@github.com:generic-infrastructure/terraform-gke-cluster.git"
  ref                = "feature/patches-1"
  kubernetes_version = "v1.28.3"
}

generate "providers" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}
EOF
}

# todo: use gcs backend
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {}
