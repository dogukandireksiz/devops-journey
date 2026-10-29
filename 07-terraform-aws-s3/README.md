# 07 - Terraform + AWS: S3 bucket for remote state

My first AWS project. This project creates an **S3 bucket** to store the **Terraform state** of my other projects.

## Why remote state?

Until now, every project kept its state file on my computer. That is risky:

| Local state | Remote state (S3) |
|---|---|
| If my computer breaks, Terraform forgets everything | The state is safe in the cloud |
| A teammate cannot use the state | Everyone with access uses the same state |
| Two `apply` at the same time can break the state | A **lock** stops this |
| A broken state is a disaster | **Versioning** keeps old versions |

## What it creates

| Resource | Why? |
|---|---|
| `aws_s3_bucket` | The bucket itself. Protected with `prevent_destroy` |
| `aws_s3_bucket_versioning` | Keeps every old version of a file, like a backup |
| `aws_s3_bucket_public_access_block` | Blocks all public access. State files can contain secrets |

All resources get tags from `default_tags` in the provider: `Project = "devops-journey"` and `ManagedBy = "terraform"`.

## The chicken and egg problem 🐔🥚

Where should this project keep **its own** state? Not in the bucket it creates:
the bucket does not exist before the first `apply`.
So this is a **bootstrap** project: its state stays **local**, and the other projects use the bucket.

## How to run

```bash
aws login                # sign in with the AWS CLI (region: eu-north-1)
aws sts get-caller-identity

terraform init
terraform plan
terraform apply

aws s3 ls                # the bucket should be in the list
```

`terraform destroy` fails on purpose, because of `prevent_destroy`. Nothing is deleted.

## How other projects use it

Add a `backend` block to the `terraform` block:

```hcl
terraform {
  backend "s3" {
    bucket       = "dogukan-devops-journey"
    key          = "<project>/<environment>/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
```

See the old versions of a state file:

```bash
aws s3api list-object-versions --bucket dogukan-devops-journey --prefix <project>/ \
  --query 'Versions[].{File:Key, Time:LastModified, Latest:IsLatest, Size:Size}' --output table
```

## Cost

An empty bucket is free. State files are very small.
The account is on the AWS **Free plan**: no charges, only credits are used.

## What I learned

**AWS account**
- **The new AWS experience:** My account is owned by an **AWS Builder ID**, not a classic root user.
  So I protected the Builder ID with **MFA**.
- **Never press "Upgrade" or "Activate advanced features"** on the Free plan.
- **`aws login`** gives temporary credentials from the browser. No passwords or access keys on disk.
- **ARN** (Amazon Resource Name) is the unique address of everything in AWS.
- **Assumed role:** I work with a role (`AccountFullAccessRole`). Full access means I must read every `plan` carefully.

**Terraform + AWS**
- **The AWS provider found the `aws login` credentials by itself**, like the Kubernetes provider finds kubeconfig.
- **Semantic versioning:** `MAJOR.MINOR.PATCH`. `~> 6.71` allows `6.72` but not `7.0`. `~> 6.71.0` allows only patches.
- **S3 bucket names are global:** unique in all of AWS, for all customers.
- **S3 settings are separate resources** (single responsibility), connected with references.
- **`default_tags`:** One block in the provider adds tags to every resource (DRY).
- **`force_destroy = false`** (default): Terraform cannot delete a bucket with files in it.
- **`prevent_destroy`:** Terraform stops at `plan` if a resource would be destroyed.
- **Writing a default setting explicitly** (like the public access block) documents the intent and catches drift.

**Remote state**
- **The `backend` block** decides where the state is stored. The default is `local`.
- **No variables or references in a backend block:** Terraform reads it before anything else.
- **Backend ≠ provider:** A Kubernetes project can store its state in S3 without the AWS provider.
- **Terraform asks to migrate the state only if the local state is not empty.**
- **The lock in action:** With versioning, I could see the `.tflock` file: lock → write state → unlock.