# Practical GitOps

## Chapter 8 - Authentication and Authorization

```bash
# Install gnupg
# Ubuntu
# sudo apt install gnupg
# MacOS
# brew install gnupg
gpg  --generate-key
gpg --list-keys
# The <public-key-id> parameter can be found from above command
# Generate public key and store it in the data folder
gpg --export <public-key-id> | base64 > data/user.pub

# If your getting a decryption error like 
export GPG_TTY=$(tty)
echo '<base64-encrypted-content>' | base64 -d | gpg --decrypt

export AWS_PROFILE=<username>
REGION=$(terraform output -raw region)
CLUSTER=$(terraform output -raw cluster_name)
aws eks --region $REGION update-kubeconfig --name $CLUSTER
export AWS_PROFILE=<username>
kubectl get pods
```