data "kubectl_file_documents" "fluentbit_yaml_count" {
  content = file("./modules/logging/fluentbit.yaml")
}

# Create the OpenSearch and OpenDashboard Cluster with Fluent-Bit Daemon
module "logging" {
  source = "./modules/logging"

  es_instance_type     = "t3.medium.elasticsearch"
  es_instance_count    = 1
  es_version           = "OpenSearch_1.2"
  fb_version           = "2.23.3"
  oidc_url             = module.eks.cluster_oidc_issuer_url
  oidc_arn             = module.eks.oidc_provider_arn
  acm_arn              = module.acm.acm_arn
  url                  = local.url
  zone_id              = data.aws_route53_zone.domain.zone_id
  environment          = var.environment
  fluentbit_count_yaml = length(data.kubectl_file_documents.fluentbit_yaml_count.documents)

  depends_on = [
    module.eks,
    resource.kubectl_manifest.aws_auth
  ]
}

# Create Prometheus and Grafana for monitoring
module "monitoring" {
  source = "./modules/monitoring"

  grafana_version    = "6.26.0"
  prometheus_version = "15.8.0"
  ms_version         = "3.8.0"
  acm_arn            = module.acm.acm_arn
  url                = local.url
  zone_id            = data.aws_route53_zone.domain.zone_id

  depends_on = [
    module.eks,
    resource.kubectl_manifest.aws_auth
  ]
}