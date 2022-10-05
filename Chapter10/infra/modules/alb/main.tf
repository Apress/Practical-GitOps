# Create an logging Bucket for ALB
data "aws_elb_service_account" "main" {}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "alb_logs" {
  bucket        = var.alb_s3_bucket
  force_destroy = true
}

resource "aws_s3_bucket_acl" "alb_logs_acl" {
  bucket = aws_s3_bucket.alb_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "allow_alb_logging" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = templatefile("./modules/alb/s3_log.json", {
    alb_s3_bucket = var.alb_s3_bucket
    account_id    = data.aws_caller_identity.current.account_id
    elb_sa        = data.aws_elb_service_account.main.arn
  })
  depends_on = [aws_s3_bucket.alb_logs]
}

# Create an IAM Policy for to restrict permissions needed for the Load Balancer Controller for operations
resource "aws_iam_policy" "alb_iam_policy" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  policy = templatefile("./modules/alb/iam_policy.json", {
    kms_key_arn   = var.kms_key_arn
    s3_bucket_arn = aws_s3_bucket.alb_logs.arn
  })
  tags = {
    "Environment"     = var.environment
    terraform-managed = "true"
  }
}

# Attach the IAM Policy document to the above IAM Policy
data "aws_iam_policy_document" "aws-load-balancer-controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [var.oidc_arn]
      type        = "Federated"
    }
  }

}

# Create an IAM Service Role for Load Balancer
resource "aws_iam_role" "aws-load-balancer-controller" {
  assume_role_policy = data.aws_iam_policy_document.aws-load-balancer-controller.json
  name               = "aws-load-balancer-controller"

}

# IAM Policy attachment for the Service Role
resource "aws_iam_role_policy_attachment" "aws-load-balancer-controller" {
  role       = aws_iam_role.aws-load-balancer-controller.name
  policy_arn = aws_iam_policy.alb_iam_policy.arn

}

# Install the Load Balancer controller using the helm chart.
resource "helm_release" "lbc" {
  name            = "aws-load-balancer-controller"
  chart           = "aws-load-balancer-controller"
  version         = var.awslb_version
  repository      = "https://aws.github.io/eks-charts"
  namespace       = "kube-system"
  cleanup_on_fail = true

  dynamic "set" {
    for_each = {
      "clusterName"                                               = var.clustername
      "serviceAccount.name"                                       = "aws-load-balancer-controller"
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.aws-load-balancer-controller.arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
  depends_on = [aws_s3_bucket.alb_logs]
}