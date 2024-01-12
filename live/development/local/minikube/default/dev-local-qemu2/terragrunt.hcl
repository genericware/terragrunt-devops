terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=${include.envcommon.locals.ref}"
}

include "root" {
  path = find_in_parent_folders()
}

include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/minikube.hcl"
  expose = true
}

inputs = {
  cluster_name = "dev-local-qemu2"
  driver       = "qemu2"
  network      = "socket_vmnet"
}
