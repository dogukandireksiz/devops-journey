# 04 - Terraform + Kubernetes: nginx on Minikube

This project deploys nginx to a local Kubernetes cluster (Minikube), using Terraform.
It does the same job as `kubectl apply -f` with YAML files, but with Terraform code.

## Kubernetes basics

| Concept | What is it? |
|---|---|
| **Cluster** | All the computers that Kubernetes manages |
| **Node** | One computer in the cluster (Minikube has only one) |
| **Pod** | The smallest unit. A box around a container. Pods can die, and new ones get new IPs |
| **Deployment** | Manages pods. "Always keep 2 pods running." If a pod dies, it starts a new one |
| **ReplicaSet** | Created by the Deployment. Keeps the number of pods correct |
| **Service** | A stable address in front of the pods. Sends traffic to them (load balancing) |
| **Namespace** | A folder for resources. The same name can be used in different namespaces |

## Docker vs Kubernetes

| Docker (projects 01-03) | Kubernetes (this project) |
|---|---|
| `docker_container` | Pod, managed by a **Deployment** |
| Nobody restarts a dead container | The Deployment starts a new pod |
| `-p 8080:80` (port mapping) | **Service** |
| `docker_image` resource | Not needed: Kubernetes pulls the image itself |

## What it creates

| Resource | Name | Why? |
|---|---|---|
| `kubernetes_namespace_v1` | `nginx` | A folder for all resources of this app |
| `kubernetes_deployment_v1` | `nginx` | Runs **2** nginx pods |
| `kubernetes_service_v1` | `nginx` | Opens the pods to the outside on port `30000` (NodePort) |

## How it works

**Connecting to the cluster:** The Kubernetes provider reads the **kubeconfig** file (`~/.kube/config`), the same file that `kubectl` uses.
The **context** (`minikube`) chooses which cluster to use.

```
Terraform → kubernetes provider → kubeconfig → Kubernetes API → cluster
```

**Every Kubernetes resource has two parts:**
- `metadata` → "Who am I?" (name, namespace, labels)
- `spec` → "What do I want?" (replicas, image, ports...)

**Labels and selectors:** The pods get a label: `app = "nginx"`.
The Deployment and the Service find their pods with a **selector** that uses the same label.
The selector and the labels must match.

**Ports:**

```
Browser → node_port (30000) → port (80) → target_port (80)
          outside door         Service      container
```

The nginx port (`80`) is used in two places, so it is defined once in a **local** value: `local.nginx_port`.

## Requirements

- Terraform
- Minikube
- kubectl

## How to run

```bash
minikube start
kubectl get nodes          # the node should be "Ready"

terraform init
terraform validate
terraform plan             # Plan: 3 to add
terraform apply

kubectl get all -n nginx   # 1 deployment, 1 replicaset, 2 pods, 1 service
minikube service nginx -n nginx --url
```

Open the URL in your browser. You should see "Welcome to nginx!".

```bash
terraform destroy
```

## What I learned

**Kubernetes**
- **Deployment → ReplicaSet → Pods:** The pod name shows this chain, for example `nginx-84bbcb74b4-bt5ks`.
- **Labels and selectors** are like name tags: the Deployment and the Service count only the pods with their tag.
- **Service types:** `ClusterIP` (only inside the cluster), `NodePort` (open on the node, ports 30000-32767), `LoadBalancer` (in the cloud).
- **Namespaces solve name clashes:** In project `03`, I used a `site_name` prefix. In Kubernetes, namespaces do this job.
- **Deleting a namespace deletes everything inside it.**

**Terraform + Kubernetes**
- **Two layers of desired state:** Terraform manages the Deployment. Kubernetes manages the pods.
  When I deleted a pod by hand, Kubernetes started a new one at once, and `terraform plan` showed no changes.
  Terraform does not even know the pods (`terraform state list` shows only the namespace and the Deployment).
- **Contexts matter:** A wrong context means deploying to the wrong cluster.
- **`locals`:** Fixed values inside the code (`local.nginx_port`). Variables come from outside, locals come from the code itself.
- **Name things by what they are, not where they are used.**
- **Deprecated warnings:** `kubernetes_namespace` is old, `kubernetes_namespace_v1` is the new name.
  Tutorials can be old. The official docs are the real source.
- **`terraform import`:** It can bring an existing resource under Terraform's management.
- **Things made by hand can block Terraform:** An old `nginx` namespace from earlier practice caused "already exists".
  I found it with `kubectl get namespaces` (look at the AGE column) and `terraform state list`.