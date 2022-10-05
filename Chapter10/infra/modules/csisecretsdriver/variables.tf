variable "k8s_path" {
  description = "Path to K8s Manifest files"
  type        = string
}

# https://secrets-store-csi-driver.sigs.k8s.io/troubleshooting.html
variable "namespace" {
  description = "Namespace in which the pod is being deployed"
  type        = string
}

variable "count_files" {
  description = "Count of k8s Deployment files"
  type        = number
}

variable "csi_secrets_version" {
  description = "Helm chart version of the CSI secrets"
  type        = string
}
