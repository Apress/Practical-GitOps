# Install the CSI Secrets Driver using the helm chart.
resource "helm_release" "csi_secrets" {
  name            = "csi-secrets-store"
  chart           = "secrets-store-csi-driver"
  version         = var.csi_secrets_version
  repository      = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  namespace       = var.namespace
  cleanup_on_fail = true

  dynamic "set" {
    for_each = {
      "syncSecret.enabled"   = true
      "enableSecretRotation" = false
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

# Install the CSI Secrets AWS Providers DS.
# Check Periodically for newer versions https://github.com/aws/secrets-store-csi-driver-provider-aws
data "kubectl_path_documents" "csi_secrets" {
  pattern = var.k8s_path
  vars = {
    namespace = var.namespace
  }
  depends_on = [helm_release.csi_secrets]
}

# kubectl apply -f files.yaml
resource "kubectl_manifest" "csi_secrets" {
  count = var.count_files

  yaml_body = element(data.kubectl_path_documents.csi_secrets.documents, count.index)

  depends_on = [helm_release.csi_secrets]
}
