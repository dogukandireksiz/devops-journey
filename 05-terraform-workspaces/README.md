# 05 - Terraform Workspaces: dev and prod

This project deploys nginx to Kubernetes (Minikube) in **two environments**, `dev` and `prod`,
with the **same code**. It uses **Terraform workspaces**.

## What is a workspace?

**One folder, one code, but a separate state for each workspace.**

```
terraform.tfstate.d/
├── dev/terraform.tfstate    ← what Terraform created in dev
└── prod/terraform.tfstate   ← what Terraform created in prod
```

Inside the code, `terraform.workspace` gives the name of the current workspace (`"dev"` or `"prod"`).

## What changes between environments?

| Value | dev | prod | How? |
|---|---|---|---|
| Namespace | `nginx-dev` | `nginx-prod` | `"nginx-${terraform.workspace}"` |
| Replicas | `1` | `3` | `local.replicas[terraform.workspace]` |
| NodePort | `30001` | `30002` | `local.node_ports[terraform.workspace]` |

Everything else (image, port `80`, labels) is the **same**, so dev and prod run the same thing.

## How to run

```bash
minikube start
terraform init

terraform workspace new dev
terraform workspace new prod

terraform workspace select dev
terraform apply

terraform workspace select prod
terraform apply

terraform workspace show            # which workspace am I in?
kubectl get pods -n nginx-dev       # 1 pod
kubectl get pods -n nginx-prod      # 3 pods
```

## ⚠️ The weak point

`terraform destroy` is the **same command** in dev and prod.
The environment depends on a hidden choice (stored in `.terraform/environment`).
If you forget to switch, you can destroy **prod** by mistake.

Workspaces are good for quick tests and similar, temporary environments.
For real dev/prod separation, a **folder structure** is safer (see project `06`).

## What I learned

- **Same code, different settings:** dev and prod should be as similar as possible.
- **Workspaces keep separate states:** In `prod`, `plan` showed "3 to add", because prod's state was empty. It did not touch dev.
- **Maps in locals:** `{ dev = 1, prod = 3 }` with `[terraform.workspace]` picks the value. The map keys must match the workspace names.
- **Same template, same ReplicaSet ID:** The pods in both environments had the same ID (`84bbcb74b4`), which shows they run the same template.
- **A successful plan does not mean the cluster is reachable:** With an empty state, `plan` did not talk to the cluster. `apply` failed because Minikube was stopped (`no route to host`).
- **Silent answers can mislead:** `kubectl get pods -n nginx-pord` (typo) said "No resources found", not "this namespace does not exist".