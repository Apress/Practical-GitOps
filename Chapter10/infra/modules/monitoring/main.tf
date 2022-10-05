resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }
    name = "monitoring"
  }
}

resource "helm_release" "metrics-server" {
  chart           = "metrics-server"
  name            = "metrics-server"
  repository      = "https://kubernetes-sigs.github.io/metrics-server/"
  cleanup_on_fail = true
  version         = var.ms_version

}

resource "helm_release" "prometheus" {
  chart           = "prometheus"
  name            = "prometheus"
  repository      = "https://prometheus-community.github.io/helm-charts"
  namespace       = kubernetes_namespace_v1.monitoring.metadata.0.name
  cleanup_on_fail = true
  version         = var.prometheus_version

  dynamic "set" {
    for_each = {
      "alertmanager.persistentVolume.storageClass" = "gp2"
      "server.persistentVolume.storageClass"       = "gp2"
    }
    content {
      name  = set.key
      value = set.value
    }
  }

}

resource "helm_release" "grafana" {
  chart           = "grafana"
  name            = "grafana"
  repository      = "https://grafana.github.io/helm-charts"
  namespace       = kubernetes_namespace_v1.monitoring.metadata.0.name
  cleanup_on_fail = true
  version         = var.grafana_version
  values = [
    templatefile("./modules/monitoring/grafana.yaml", {
      grafana_user     = "grafana"
  # Please change or deploy AWS Secrets Manager to retrieve the password
      grafana_password = "Gr@fAna123"
      prometheus-svc   = "${helm_release.prometheus.name}-server"
      namespace        = kubernetes_namespace_v1.monitoring.metadata.0.name
      url              = var.url
      acm_arn          = var.acm_arn
      storage          = "10Gi"
    })
  ]
}



data "kubernetes_ingress" "grafana" {

  metadata {
    name      = resource.helm_release.grafana.name
    namespace = kubernetes_namespace_v1.monitoring.metadata.0.name
  }

  depends_on = [resource.helm_release.grafana]
}

# Create a sub-domain monitoring.example.com
resource "aws_route53_record" "grafana" {
  zone_id = var.zone_id
  name    = "monitoring"
  type    = "CNAME"
  ttl     = "60"

  records = [data.kubernetes_ingress.grafana.status.0.load_balancer.0.ingress.0.hostname]
}
