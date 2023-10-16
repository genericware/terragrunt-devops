resource "local_file" "akmecorp-master" {
  filename = "${path.root}/files/manifest.yaml"
  content  = <<-EOT
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
spec:
  destination:
    namespace: argocd
    server: https://kubernetes.default.svc
  project: default
  source:
    path: templates/charts/app-of-apps
    repoURL: ${var.repository_url}
    targetRevision: ${var.repository_branch}
    helm:
      valueFiles:
        - values-${var.environment}-${var.region}-${var.profile}.yaml
EOT
}
