# Create a cluster-name with org region and environment combination
locals {
  cluster_name = "${var.org_name}-${var.region}-${var.environment}"
}