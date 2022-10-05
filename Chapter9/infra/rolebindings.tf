# Fetch account ID of the current organisation
data "aws_caller_identity" "current" {}

locals {

  # Creating the AWS-AUTH
  aws_auth_configmap_yaml = <<-EOT
  ${chomp(module.eks.aws_auth_configmap_yaml)}
      - rolearn: arn:aws:iam::${data.aws_caller_identity.current.id}:role/AssumeRoleAdmin${var.environment}
        username: admin
        groups:
          - system:masters
      - rolearn: arn:aws:iam::${data.aws_caller_identity.current.id}:role/AssumeRoleDeveloper${var.environment}
        username: developer
        groups:
          - developer
      - rolearn: arn:aws:iam::${data.aws_caller_identity.current.id}:role/AssumeRoleReadOnly${var.environment}
        username: readonly
        groups:
          - readonly
  EOT

}

################# Developer Role Bindings ##################################

resource "kubernetes_role_v1" "developer" {
  metadata {
    name      = "developer"
    namespace = kubernetes_namespace_v1.app.metadata.0.name
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods", "deployments", "services", "ingresses", "namespaces", "jobs", "daemonset"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding_v1" "developer" {
  metadata {
    name      = "developer"
    namespace = kubernetes_namespace_v1.app.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "developer"
  }
  subject {
    kind      = "Group"
    name      = "developer"
    api_group = "rbac.authorization.k8s.io"
  }
}

################# Readonly Role Bindings ##################################

resource "kubernetes_role_v1" "readonly" {
  metadata {
    name      = "readonly"
    namespace = kubernetes_namespace_v1.app.metadata.0.name
  }

  rule {
    api_groups = ["*"]
    resources  = ["pods", "deployments", "services", "ingresses", "namespaces", "jobs", "daemonset"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "readonly" {
  metadata {
    name      = "readonly"
    namespace = kubernetes_namespace_v1.app.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "readonly"
  }
  subject {
    kind      = "Group"
    name      = "readonly"
    api_group = "rbac.authorization.k8s.io"
  }
}

################# Apply AWS Auth ConfigMap ##################################

resource "kubectl_manifest" "aws_auth" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/managed-by: Terraform
  name: aws-auth
  namespace: kube-system
${local.aws_auth_configmap_yaml}
YAML

  depends_on = [module.eks]

}