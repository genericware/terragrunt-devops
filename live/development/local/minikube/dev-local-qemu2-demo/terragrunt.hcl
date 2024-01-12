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
  cluster_name = "dev-local-qemu2-demo"
  driver       = "qemu2"
  network      = "socket_vmnet"
  nodes        = 1
  cpus         = 8
  memory       = 8192
  disk_size    = 102400
  extra_disks  = 0
}
