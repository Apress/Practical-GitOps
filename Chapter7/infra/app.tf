################# Create Namespace ##################################

resource "kubernetes_namespace_v1" "app" {
  metadata {
    annotations = {
      name = var.org_name
    }
    name = var.org_name
  }
  depends_on = [module.eks]
}

################# Deploy Application ##################################

# Read the database password
module "ssmr-db-password" {
  source = "./modules/ssmr"

  parameter_name = "db_password"
  parameter_path = "/${var.org_name}/database"

  depends_on = [module.ssmw-db-password]
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = var.org_name
    namespace = kubernetes_namespace_v1.app.metadata.0.name
    labels = {
      app = var.org_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.org_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.org_name
        }
      }

      spec {
        container {
          image = "salecharohit/practicalgitops"
          name  = var.org_name
          env {
            name  = "DB_PORT"
            value = "5432"
          }
          env {
            name  = "DB_HOST"
            value = module.pgsql.db_instance_address
          }
          env {
            name  = "DB_NAME"
            value = var.db_name
          }
          env {
            name  = "DB_USERNAME"
            value = var.db_user_name
          }
          env {
            name  = "DB_PASSWORD"
            value = module.ssmr-db-password.ssm-value
          }

          port {
            container_port = "8080"
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "1"
              memory = "300Mi"
            }
            requests = {
              cpu    = "0.25"
              memory = "200Mi"
            }
          }

          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = [
                "SETUID",
                "SETGID"
              ]
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = var.org_name
    namespace = kubernetes_namespace_v1.app.metadata.0.name
  }
  spec {
    port {
      port        = 8080
      target_port = 8080
    }
    selector = {
      app = var.org_name
    }
    type = "NodePort"
  }
  depends_on = [kubernetes_deployment_v1.app]
}

resource "kubernetes_ingress_v1" "app" {
  wait_for_load_balancer = true
  metadata {
    name      = var.org_name
    namespace = kubernetes_namespace_v1.app.metadata.0.name
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/certificate-arn" = module.acm.acm_arn
      "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
    }
  }
  spec {
    rule {
      host = local.url
      http {
        path {
          backend {
            service {
              name = var.org_name
              port {
                number = 8080
              }
            }
          }
          path = "/*"
        }
      }
    }
  }
  depends_on = [module.alb_ingress, kubernetes_ingress_v1.app]
}