# Practical GitOps

## Chapter 8 - Infra Setup

```bash
export org_name="practicalgitops"
export region=us-east-2

REGION=$(terraform output -raw region)
CLUSTER=$(terraform output -raw cluster_name)
aws eks --region $REGION update-kubeconfig --name $CLUSTER

delete load balancer
LB_arn=$(aws elbv2 describe-load-balancers --region=$REGION --query 'LoadBalancers[*].LoadBalancerArn' --output text)
aws elbv2 delete-load-balancer --load-balancer-arn $LB_arn --region $REGION

```