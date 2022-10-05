# Create an IAM Policy for to restrict permissions needed for the Load Balancer Controller for operations
resource "aws_iam_policy" "alb_iam_policy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = file("./modules/alb/iam_policy.json")
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

}