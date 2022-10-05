locals {
  namespace      = "logging"
  es_domain_name = "eslogging"
  es_username    = "elastic"
  # Please change or deploy AWS Secrets Manager to retrieve the password
  es_password = "Elastic@123"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Create logging namesapce
resource "kubernetes_namespace_v1" "logging" {
  metadata {
    annotations = {
      name = local.namespace
    }
    name = local.namespace
  }
}

# Create FluentBit IAM Policy to write to Elasticsearch Cluster
resource "aws_iam_policy" "fb_policy" {
  name = "fb_policy"
  path = "/"
  policy = templatefile("./modules/logging/fluentbit.json", {
    aws_region     = data.aws_region.current.name
    account_id     = data.aws_caller_identity.current.account_id
    es_domain_name = local.es_domain_name
  })
}

# Create IAM Role Service Account for fluent-bit
resource "kubernetes_service_account" "irsa_fluentbit" {
  metadata {
    name      = "irsa-fluentbit"
    namespace = kubernetes_namespace_v1.logging.metadata.0.name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa_fluentbit.arn
    }
  }
  automount_service_account_token = true
}

# Create an IAM Policy document for AssumingRolewith Web Identity and federated using OIDC
data "aws_iam_policy_document" "irsa_fluentbit" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.namespace}:irsa-fluentbit"]
    }

    principals {
      identifiers = [var.oidc_arn]
      type        = "Federated"
    }
  }
}

# Create an IAM role for fluent-bit assumable by fluent-bit Daemonsets
resource "aws_iam_role" "irsa_fluentbit" {
  name               = "FluentbitRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.irsa_fluentbit.json
}

resource "aws_iam_role_policy_attachment" "irsa_fluentbit" {
  role       = aws_iam_role.irsa_fluentbit.name
  policy_arn = aws_iam_policy.fb_policy.arn
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
  description      = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}

# Create OpenSearch Cluster
resource "aws_elasticsearch_domain" "es" {
  domain_name     = local.es_domain_name
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:ESHttp*",
      "Principal": {
        "AWS": "*"
      },
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${local.es_domain_name}/*"
    }
  ]
}
POLICY

  elasticsearch_version = var.es_version

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"

    custom_endpoint_enabled         = true
    custom_endpoint                 = "logging.${var.url}"
    custom_endpoint_certificate_arn = var.acm_arn
  }
  encrypt_at_rest {
    enabled = true
  }
  node_to_node_encryption {
    enabled = true
  }
  cluster_config {
    instance_type            = var.es_instance_type
    instance_count           = var.es_instance_count
    zone_awareness_enabled   = false
    dedicated_master_enabled = false
  }
  ebs_options {
    ebs_enabled = "true"
    volume_type = "gp2"
    volume_size = 100
  }
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = local.es_username
      master_user_password = local.es_password
    }
  }
  tags = {
    "Environment"     = var.environment
    terraform-managed = "true"
    "Domain"          = local.es_domain_name
  }
  depends_on = [
    aws_iam_service_linked_role.es
  ]
}

# Create a sub-domain logging.example.com
resource "aws_route53_record" "opensearch" {
  zone_id = var.zone_id
  name    = "logging"
  type    = "CNAME"
  ttl     = "60"

  records = [aws_elasticsearch_domain.es.endpoint]
}

# Enable full access to the fluent-bit role
resource "null_resource" "fluentbit-role" {
  provisioner "local-exec" {
    command = <<EOT
        curl -sS -u "${local.es_username}:${local.es_password}" -X PATCH \
        https://${aws_elasticsearch_domain.es.endpoint}/_opendistro/_security/api/rolesmapping/all_access?pretty \
        -H 'Content-Type: application/json' \
        -d'
        [
          {
            "op": "add", "path": "/backend_roles", "value": ["'${aws_iam_role.irsa_fluentbit.arn}'"]
          }
        ]
        '
EOT
  }
  triggers = {
    endpoint = aws_elasticsearch_domain.es.endpoint
  }

  depends_on = [resource.aws_elasticsearch_domain.es]
}

# Check Periodically for newer versions https://github.com/aws/aws-for-fluent-bit
data "kubectl_path_documents" "fluentbit_yaml_parse" {
  pattern = "./modules/logging/fluentbit.yaml"
  vars = {
    es_endpoint          = aws_elasticsearch_domain.es.endpoint
    aws_region           = data.aws_region.current.name
    namespace            = kubernetes_namespace_v1.logging.metadata.0.name
    service_account_name = resource.kubernetes_service_account.irsa_fluentbit.metadata[0].name
    fb_version           = var.fb_version
  }
}

# Install fluent-bit
resource "kubectl_manifest" "fluentbit_yaml_apply" {
  count = var.fluentbit_count_yaml

  yaml_body = element(data.kubectl_path_documents.fluentbit_yaml_parse.documents, count.index)

  depends_on = [resource.null_resource.fluentbit-role,
  resource.kubernetes_service_account.irsa_fluentbit]
}