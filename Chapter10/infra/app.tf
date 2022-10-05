################# Create Namespace ##################################

resource "kubernetes_namespace_v1" "app" {
  metadata {
    annotations = {
      name = var.org_name
    }
    name = var.org_name
  }
  depends_on = [module.eks, resource.kubectl_manifest.aws_auth]
}

################ Install CSI Driver ################################

data "kubectl_file_documents" "csi_secrets" {
  content = file("modules/csisecretsdriver/aws-secrets-csi.yaml")
}

# Install the CSI Secrets Driver with Secrets Sync Enabled
module "csi-secrets-driver" {

  source = "./modules/csisecretsdriver"

  count_files         = length(data.kubectl_file_documents.csi_secrets.documents)
  csi_secrets_version = "1.1.2"
  k8s_path            = "modules/csisecretsdriver/aws-secrets-csi.yaml"
  namespace           = kubernetes_namespace_v1.app.metadata.0.name

  depends_on = [module.eks, resource.kubernetes_namespace_v1.app]

}

################# Create Service Accounts ###########################

resource "aws_iam_policy" "secrets_policy" {
  name = "secrets_policy"
  path = "/"
  policy = templatefile("./data/secrets.json", {
    db_password_arn = module.awssm-db-password.arn
  })
}

module "irsa_aws_secrets" {
  source = "./modules/irsa"

  oidc_url         = module.eks.cluster_oidc_issuer_url
  oidc_arn         = module.eks.oidc_provider_arn
  k8s_sa_namespace = kubernetes_namespace_v1.app.metadata.0.name
  k8s_irsa_name    = "irsa-aws-secrets"
  policy_arn       = resource.aws_iam_policy.secrets_policy.arn

  depends_on = [module.eks, resource.kubernetes_namespace_v1.app]
}

resource "kubernetes_service_account" "irsa_aws_secrets" {
  metadata {
    name      = module.irsa_aws_secrets.role_name
    namespace = kubernetes_namespace_v1.app.metadata.0.name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa_aws_secrets.role_arn
    }
  }
  automount_service_account_token = true
  depends_on                      = [module.eks, resource.kubernetes_namespace_v1.app]
}

################# Read Secrets #######################################

resource "kubectl_manifest" "secrets" {
  yaml_body = <<YAML
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: aws-secret-application
  namespace: ${var.org_name}
spec:
  provider: aws
  secretObjects:
    - secretName: db-password-secret
      type: Opaque
      data:
        - objectName: ${var.db_pwd_parameter_name}
          key: db_password
  parameters:
    objects: |
      - objectName: ${var.db_pwd_parameter_name}
        objectType: "secretsmanager"
YAML

  depends_on = [module.pgsql,
    module.csi-secrets-driver,
    resource.kubernetes_namespace_v1.app
  ]

}

################# Deploy Application ##################################

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
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "db-password-secret"
                key  = "db_password"
              }
            }
          }

          volume_mount {
            name       = "db-password-vol"
            mount_path = "/mnt/secrets-store"
            read_only  = true
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

        volume {
          name = "db-password-vol"
          csi {
            driver    = "secrets-store.csi.k8s.io"
            read_only = true
            volume_attributes = {
              "secretProviderClass" = "aws-secret-application"
            }
          }
        }

        service_account_name = resource.kubernetes_service_account.irsa_aws_secrets.metadata[0].name
      }
    }
  }

  depends_on = [module.pgsql,
    module.csi-secrets-driver,
    resource.kubectl_manifest.secrets,
    resource.kubernetes_namespace_v1.app
  ]
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
      "kubernetes.io/ingress.class"                        = "alb"
      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"              = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"          = module.acm.acm_arn
      "alb.ingress.kubernetes.io/listen-ports"             = "[{\"HTTP\": 80}, {\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/actions.ssl-redirect"     = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
      "alb.ingress.kubernetes.io/load-balancer-attributes" = "access_logs.s3.enabled=true,access_logs.s3.bucket=${var.alb_s3_bucket},access_logs.s3.prefix=gitops,routing.http.drop_invalid_header_fields.enabled=true"
      "alb.ingress.kubernetes.io/group.name"               = "gitops"
    }
  }
  spec {
    rule {
      host = local.url
      http {
        path {
          backend {
            service {
              name = "ssl-redirect"
              port {
                name = "use-annotation"
              }
            }
          }
          path = "/*"
        }
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

  depends_on = [module.alb_ingress, kubernetes_deployment_v1.app]
}