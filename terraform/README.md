# Terraform Deployment

This directory contains Terraform code to provision the **ledger-api** and its external dependencies as service abstractions in Kubernetes.

## Prerequisites

- Terraform version `>= 1.5.0`
- Configured local Kubeconfig context in `/Users/vennpham/.kube/config` pointing to your active cluster.

## Resources Provisioned

- `kubernetes_service` & `kubernetes_endpoints` pointing `postgres` DNS to IP `192.168.122.245`.
- `kubernetes_service` & `kubernetes_endpoints` pointing `redis` DNS to IP `192.168.122.203`.
- `kubernetes_config_map` holding non-sensitive app settings.
- `kubernetes_secret` holding the sensitive database URL connection string.
- `kubernetes_deployment` (3 replicas, rolling updates, security configurations, probes, resources limits).
- `kubernetes_service` (ClusterIP).
- `kubernetes_pod_disruption_budget_v1`.
- `kubernetes_network_policy`.

## Usage Instructions

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Secret Management with Mozilla SOPS (Local Execution)
For security, production secrets are encrypted using `getsops/sops`. You can feed these secrets into Terraform using three different methods:

#### Method A: Temporary Decrypted File (Recommended)
Decrypt the encrypted variable file into `.terraform.tfvars` (which is ignored by Git in `.gitignore`):
```bash
# Decrypt variables file
sops -d secrets.enc.tfvars > .terraform.tfvars

# Run Terraform plan/apply
terraform plan -out=tfplan
terraform apply tfplan

# (Optional) Remove the decrypted file when done
rm .terraform.tfvars
```

#### Method B: In-Memory Decryption (Process Substitution)
To avoid writing decrypted secrets to the disk at all, pass the decrypted file descriptors directly:
```bash
terraform plan -var-file=<(sops -d secrets.enc.tfvars) -out=tfplan
terraform apply tfplan
```

#### Method C: Env-Var injection
If using environment variables, use the `sops exec-env` wrapper:
```bash
sops exec-env secrets.enc.tfvars "terraform apply"
```

### 3. Verify Deployments
You can use `kubectl` to confirm resources are running in the target namespace:
```bash
kubectl get deployments,services,pods -n ledger-api
```

### 4. Destroy Infrastructure
To delete all resources provisioned by Terraform:
```bash
# If using a decrypted .tfvars file
terraform destroy

# If decrypting on the fly
terraform destroy -var-file=<(sops -d secrets.enc.tfvars)
```


### Verify the deployment
https://ledger-mm-test.vennpham.work/
![alt text](image.png)

