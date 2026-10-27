# DevOps Journey 🚀

My hands-on DevOps learning journey, following the [90DaysOfDevOps](https://github.com/MichaelCade/90DaysOfDevOps) course.

I am a Software Engineering student. In this repo, I write every project **by myself**, step by step.
My goal is not to copy code, but to understand **why** things work.

## 🗺️ Roadmap

| Phase | Topic | Status |
|---|---|---|
| 1 | **Terraform:** Docker, variables, modules, Kubernetes, environments, testing | ✅ Done |
| 2 | **AWS + Terraform:** EC2, VPC, S3 | 🔜 Next |
| 3 | **Ansible:** Configuring servers | ⏳ |
| 4 | **CI/CD:** Jenkins (basics), GitHub Actions, ArgoCD | ⏳ |
| 5 | **Monitoring & Logging:** Prometheus, Grafana, ELK/EFK | ⏳ |
| 6 | **Data protection:** Backup and disaster recovery | ⏳ |

From phase 2, the projects grow into **one main project** on AWS:
Terraform creates the infrastructure, Ansible configures it, GitHub Actions deploys it,
and monitoring and backups protect it.

## 📁 Projects

| # | Project | What I built | Key concepts |
|---|---|---|---|
| 01 | [terraform-docker-nginx](./01-terraform-docker-nginx) | nginx in Docker with Terraform | Providers, state, image vs container, references, drift |
| 02 | [terraform-wordpress-mysql](./02-terraform-wordpress-mysql) | WordPress + MySQL, two containers | Network, volume, env, interpolation, variables, outputs, sensitive |
| 03 | [terraform-modules](./03-terraform-modules) | One module, two WordPress sites | Modules, prefixes, debugging with logs |
| 04 | [terraform-kubernetes-nginx](./04-terraform-kubernetes-nginx) | nginx on Kubernetes (Minikube) | Namespace, Deployment, Service, labels, locals |
| 05 | [terraform-workspaces](./05-terraform-workspaces) | dev and prod with workspaces | Workspaces, maps, separate states |
| 06 | [terraform-environments](./06-terraform-environments) | dev and prod with folders + tests | Environment folders, validation, `terraform test`, tflint |

Every project has its own README with **how to run it** and **what I learned**.

## 🧰 Tools

- **Infrastructure as Code:** Terraform
- **Containers:** Docker
- **Orchestration:** Kubernetes (Minikube, kubectl)
- **Quality and security:** `terraform test`, tflint, Trivy
- **Version control:** Git, GitHub, Conventional Commits

