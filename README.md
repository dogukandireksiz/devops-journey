# DevOps Journey 🚀

My hands-on DevOps learning journey, following the [90DaysOfDevOps](https://github.com/MichaelCade/90DaysOfDevOps) course.

I am a Software Engineering student. In this repo, I write every project **by myself**, step by step.
My goal is not to copy code, but to understand **why** things work.

## 🗺️ Roadmap

| Phase | Topic | Status |
|---|---|---|
| 1 | **Terraform:** Docker, variables, modules, Kubernetes, environments, testing | ✅ Done |
| 2 | **AWS + Terraform:** S3, VPC, EC2 | ✅ Done |
| 3 | **Ansible:** Configuring servers | 🔜 Next |
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
| 07 | [terraform-aws-s3](./07-terraform-aws-s3) | S3 bucket for remote state | AWS login, S3, versioning, `prevent_destroy`, remote state, locking |
| 08 | [terraform-aws-vpc](./08-terraform-aws-vpc) | My own network in AWS | VPC, CIDR, subnets, Internet Gateway, route tables, AZs |
| 09 | [terraform-aws-ec2](./09-terraform-aws-ec2) | EC2 server + SSH + web page | Data sources, AMIs, key pairs, Security Groups, NAT, `user_data` |

Every project has its own README with **how to run it** and **what I learned**.

## 🧰 Tools

- **Infrastructure as Code:** Terraform
- **Containers:** Docker
- **Orchestration:** Kubernetes (Minikube, kubectl)
- **Cloud:** AWS (S3, VPC, EC2), AWS CLI
- **Quality and security:** `terraform test`, tflint, Trivy
- **Version control:** Git, GitHub, Conventional Commits

## 💡 Lessons that I keep learning again

- **Valid is not the same as correct.** `terraform validate` can say "Success" when the code is wrong.
- **A successful `apply` does not mean the system works.** Always check the real result.
- **Running is not the same as ready.** A server or a database needs time after it starts.
- **"No problems found" does not mean "no problems".** Every tool sees only its own area.
- **Read every plan.** An unexpected `destroy` line shows a problem before it happens.
- **Read the logs, don't guess.**
- **Least privilege:** Give each user, rule and door only the access it needs.
- **Never commit secrets or state files.** Git remembers everything.
- **Tutorials get old.** The official documentation is the real source.

## 🔒 What is not in this repo

`.terraform/` folders, `*.tfstate` files and `terraform.tfvars` files are in `.gitignore`.
Each project with secrets has a `terraform.tfvars.example` file to show which values are needed.
Remote state lives in an S3 bucket (project `07`), and SSH private keys never leave my computer.