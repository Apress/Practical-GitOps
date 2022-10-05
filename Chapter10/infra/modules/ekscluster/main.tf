# Create an EKS Cluster with Nodegroups in Private subnet
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.0"
  cluster_name    = var.clustername
  cluster_version = var.eks_version
  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id
  enable_irsa     = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }]

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {

    ingress_allow_access_from_control_plane = {
      type                          = "ingress"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      source_cluster_security_group = true
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
    }

    ingress_nodes_karpenter_ports_tcp = {
      description                   = "Karpenter readiness"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # Default Settings applicable to all node groups
  eks_managed_node_group_defaults = {
    ami_type          = "AL2_x86_64"
    disk_size         = 50
    ebs_optimized     = true
    enable_monitoring = true
    instance_types    = var.instance_types
    capacity_type     = "ON_DEMAND"
    desired_size      = 1
    max_size          = 3
    min_size          = 1
    update_config = {
      max_unavailable_percentage = 50
    }

    ebs_optimized     = true
    enable_monitoring = true

    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 75
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 150
          encrypted             = true
          kms_key_id            = ""
          delete_on_termination = true
        }
      }
    }

    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 2
      instance_metadata_tags      = "disabled"
    }
  }

  eks_managed_node_groups = {

    system = {
      name            = "system"
      use_name_prefix = true

      tags = {
        Name              = "system"
        Environment       = var.environment
        terraform-managed = "true"
      }
    },
    app = {
      name            = "app"
      use_name_prefix = true

      tags = {
        Name              = "app"
        Environment       = var.environment
        terraform-managed = "true"
      }
    }
  }

  tags = {
    Name                     = var.clustername
    Environment              = var.environment
    terraform-managed        = "true"
    "karpenter.sh/discovery" = var.clustername
  }

}