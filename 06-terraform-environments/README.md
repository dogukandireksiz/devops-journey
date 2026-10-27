# 06 - Terraform Environments: dev and prod with folders

This project deploys nginx to Kubernetes (Minikube) in **two environments**, `dev` and `prod`.
This time, each environment has its **own folder**, and both folders call the **same module**.

Compare it with project `05`, which does the same job with **workspaces**.

## Folder structure

```
06-terraform-environments/
├── modules/
│   └── nginx/
│       ├── main.tf          # Namespace + Deployment + Service
│       └── variables.tf     # environment, replicas, node_port
└── environments/
    ├── dev/
    │   └── main.tf          # Provider + module call with dev values
    └── prod/
        └── main.tf          # Provider + module call with prod values
```

- **The module** knows **how** to deploy nginx.
- **Each environment folder** decides **where** (provider and cluster) and **with which values**.
- Each environment folder is a separate root module, so each has its **own state**.

## Environments

| Value | dev | prod |
|---|---|---|
| `environment` | `dev` | `prod` |
| Namespace | `nginx-dev` | `nginx-prod` |
| `replicas` | `1` | `3` |
| `node_port` | `30001` | `30002` |

The values are written directly in `environments/dev/main.tf` and `environments/prod/main.tf`.
They are not secret, and anyone can see all the settings of an environment in one file.

## Module variables

| Name | Type | Validation |
|---|---|---|
| `environment` | string | Must be `dev` or `prod` |
| `replicas` | number | - |
| `node_port` | number | Must be between 30000 and 32767 |

**Validation** checks the value before anything is created.
For example, `node_port = 8080` fails at `terraform plan` with a clear error message.

Validation cannot check if a port is already used by another environment.
Each environment has its own state and does not know the others. Kubernetes checks this at `apply` time.

## How to run

```bash
minikube start

cd environments/dev
terraform init
terraform apply

cd ../prod
terraform init
terraform apply

kubectl get pods -n nginx-dev     # 1 pod
kubectl get pods -n nginx-prod    # 3 pods
```

Always check your terminal: it shows which folder (environment) you are in.

## Workspaces (05) vs Folders (06)

| | Workspaces (05) | Folders (06) |
|---|---|---|
| Code | One `main.tf` | One module + a small `main.tf` for each environment |
| State | `terraform.tfstate.d/dev`, `/prod` | One state in each environment folder |
| Choosing the environment | **Hidden** (`terraform workspace select`) | **Visible** (`cd environments/dev`) |
| Different values | Maps + `terraform.workspace` | Values in the module block |
| Provider / cluster | The same for all | Each environment can use its own |
| Best for | Quick, temporary, similar environments | Real dev / prod separation |



## Tests

The module has tests in `modules/nginx/tests/nginx.tftest.hcl`:

| Test | Checks |
|---|---|
| `dev_values` | With `environment = "dev"`, the namespace is `nginx-dev` and the NodePort is `30001` |
| `invalid_node_port` | `node_port = 8080` must fail the validation |

```bash
cd modules/nginx
terraform init
terraform test     # Success! 2 passed, 0 failed.
```

The tests use `command = plan`, so they do not create anything.

## What I learned

- **The provider configuration belongs in the root module, not in the child module.**
  The module says *how*, the environment says *where*. So prod could use a different cluster than dev.
- **`source` paths:** `../` means "one folder up". From `environments/dev`, the module is two folders up: `../../modules/nginx`.
  A path without `./` or `../` makes Terraform look in the online Terraform Registry.
- **Module arguments must match the module's variables.** A leftover argument (`site_name` from project `03`) gives "Unsupported argument".
- **Validation:** `condition` must be `true` for a valid value, and `error_message` is shown when it is `false`.
  Use `var.<name>` in the condition, not the type name (`number`).
- **Built-in functions:** `contains(["dev", "prod"], var.environment)` checks if a value is in a list.
- **Each check works where the information is:** type → right kind, validation → right range, Kubernetes → port not used.
- **Terraform reads only the folder you are in:** Running `terraform plan` in the parent folder gave "No configuration files".
  `terraform validate` said "Success", because empty code has no errors. 😄



