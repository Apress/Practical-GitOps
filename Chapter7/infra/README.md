# Practical GitOps

## Chapter 7 - 

```bash

aws route53 create-hosted-zone --name gitops.rohitsalecha.com --caller-reference 2022-01-20-24:35
aws route53 list-hosted-zones
aws route53 delete-hosted-zone --id Z09740762V0VBII120RGX


REGION=$(terraform output -raw region)
CLUSTER=$(terraform output -raw cluster_name)
aws eks --region $REGION update-kubeconfig --name $CLUSTER

delete load balancer
LB_arn=$(aws elbv2 describe-load-balancers --region=$REGION --query 'LoadBalancers[*].LoadBalancerArn' --output text)
aws elbv2 delete-load-balancer --load-balancer-arn $LB_arn --region $REGION

```
