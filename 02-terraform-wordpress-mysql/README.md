# 02 - Terraform + Docker: WordPress and MySQL

This project runs a WordPress website with a MySQL database, using Terraform and Docker.
Two containers work together: WordPress saves its data in MySQL.

## What it creates

| Resource | Name | Why? |
|---|---|---|
| `docker_network` | `wordpress-db-network` | The two containers talk to each other on this network |
| `docker_volume` | `mysql-volume` | Keeps MySQL data safe when the container is deleted |
| `docker_image` | `mysql` | MySQL image |
| `docker_image` | `wordpress` | WordPress image |
| `docker_container` | `db` | MySQL database |
| `docker_container` | `wordpress_container` | WordPress website |

## How it works

- Both containers are on the same **network**. WordPress finds MySQL by its name: `db`.
- MySQL writes its data to `/var/lib/mysql` inside the container.
  The **volume** is mounted there, so the data lives outside the container.
- Settings like the database name, user and password come from **variables**.
  Terraform passes them to the containers as **environment variables**.

## Files

| File | What is inside? | In Git? |
|---|---|---|
| `main.tf` | Resources | ✅ |
| `variables.tf` | Variable definitions | ✅ |
| `outputs.tf` | Outputs | ✅ |
| `terraform.tfvars.example` | Example values (fake) | ✅ |
| `terraform.tfvars` | Real values and passwords | ❌ (in `.gitignore`) |

## Variables

| Name | Type | Default | Sensitive | Description |
|---|---|---|---|---|
| `db_name` | string | - | No | Name of the MySQL database for WordPress |
| `db_user` | string | `admin` | No | Normal (not root) MySQL user for WordPress |
| `db_password` | string | - | Yes | Password for `db_user` |
| `db_root_password` | string | - | Yes | Password for the MySQL root user |
| `wordpress_port` | number | `8080` | No | Port on your computer for opening WordPress |

## Outputs

| Name | Example |
|---|---|
| `wordpress_url` | `http://localhost:8080` |

## How to run

1. Copy the example file and write your own values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Run Terraform:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

3. Open the `wordpress_url` from the output in your browser.
   If you see "Error establishing a database connection", wait 20-30 seconds.
   MySQL needs some time to get ready.

```bash
terraform destroy   # deletes everything, including the volume!
```

## ⚠️ Changing the database password

MySQL uses the environment variables **only on the first start**, when the volume is empty.
If you change `db_password` later, the password inside the database does **not** change.
WordPress gets the new password, but MySQL still has the old one, so the connection fails.

To change it:
1. Change the password inside MySQL first (`ALTER USER ... IDENTIFIED BY ...`).
2. Then update `terraform.tfvars` and run `terraform apply`.

## What I learned

**Day 1-2: Network, volume and containers**

- **Network:** Containers on the same Docker network can find each other by name (DNS).
- **Volume:** Data in a volume stays, even when the container is deleted. But `terraform destroy` deletes the volume too.
- **Environment variables:** The format is `"NAME=value"`, with no spaces.
- **Interpolation:** `"${docker_container.db_container.name}"` puts a reference inside a string.
  Terraform can see the dependency, so it creates MySQL before WordPress.
- **Order in the file does not matter:** Terraform reads all blocks and decides the order from the references.
- **Terraform only knows its own resources:** It manages only what is in its state file (`terraform state list`).
- **"Container is running" is not the same as "the app is ready".**

**Day 3: Variables and outputs**

- **Variables are like function parameters, outputs are like return values.**
- **DRY:** One variable (like `db_password`) is used in both containers, so the values always match.
- **Not everything should be a variable:** If the software decides a value (port `80`, `/var/lib/mysql`), it stays fixed.
- **Types protect you:** `number`, `string`, `bool`... A wrong value fails early.
- **`terraform.tfvars`:** Real values live here, and this file is not in Git.
- **Sensitive is "contagious":** If a list has one sensitive value, Terraform hides the whole list.
  But the state file still has the real values.
- **A successful `apply` does not mean the system works:** Terraform manages the infrastructure, not the data inside the app.
- **Git remembers everything:** A password in an old commit is still visible. If a secret goes to GitHub, change it.