terraform {
  backend "local" {
    path = "${path.module}/terraform.tfstate"
  }
}
