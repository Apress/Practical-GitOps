locals {
  namespace = "karpenter"
}

data "aws_iam_policy" "ssm_managed_instance" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "karpenter_ssm_policy" {
  role       = var.node_group_role_arn
  policy_arn = data.aws_iam_policy.ssm_managed_instance.arn
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile"
  role = var.node_group_role_arn
}

resource "aws_iam_policy" "karpenter_policy" {
  name   = "karpenter_policy"
  path   = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "KarpenterPolicy",
            "Effect": "Allow",
            "Action": [
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:RunInstances",
                "ec2:CreateTags",
                "iam:PassRole",
                "ec2:TerminateInstances",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ssm:GetParameter"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# Create an IAM Policy document for AssumingRolewith Web Identity and federated using OIDC
data "aws_iam_policy_document" "karpenter_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.namespace}:${local.namespace}"]
    }

    principals {
      identifiers = [var.oidc_arn]
      type        = "Federated"
    }
  }
}

# Create an IAM role for fluent-bit assumable by fluent-bit Daemonsets
resource "aws_iam_role" "irsa_karpenter" {
  name               = "KarpenterRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
}

resource "aws_iam_role_policy_attachment" "irsa_fluentbit" {
  role       = aws_iam_role.irsa_karpenter.name
  policy_arn = aws_iam_policy.karpenter_policy.arn
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  chart            = "karpenter"
  version          = var.karpenter_version
  repository       = "https://charts.karpenter.sh"
  create_namespace = true
  namespace        = local.namespace
  cleanup_on_fail  = true

  dynamic "set" {
    for_each = {
      "controller.clusterName"                                    = var.eks_cluster_id
      "controller.clusterEndpoint"                                = var.eks_cluster_endpoint_url
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.irsa_karpenter.arn
      "aws.defaultInstanceProfile"                                = aws_iam_instance_profile.karpenter.name
    }
    content {
      name  = set.key
      value = set.value
    }
  }

}

resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata: 
  name: default
spec:
  requirements:
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["on-demand"]
    - key: "node.kubernetes.io/instance-type"
      operator: In
      values: ["t3.small", "t3.micro"]
  limits:
    resources:
      cpu: 1000
  provider:
    instanceProfile: ${aws_iam_instance_profile.karpenter.name} 
    subnetSelector:
      karpenter.sh/discovery: ${var.eks_cluster_id}
    securityGroupSelector:
      karpenter.sh/discovery: ${var.eks_cluster_id}
  ttlSecondsAfterEmpty: 30
YAML

  depends_on = [resource.helm_release.karpenter]

}
