# Practical GitOps

## Chapter 9 - Infra Setup

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

Check Connectivity

kubectl run test1 -it -n logging --rm=true --image=busybox --restart=Never -n default -- wget -O - http://elasticsearch-master:9200

Force Delete

kubectl delete pod elasticsearch-master-0 --grace-period=0 --force --namespace logging

