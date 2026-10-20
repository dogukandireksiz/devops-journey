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
| `docker_container` | `wordpress_container` | WordPress website, on port `8080` |

## How it works

- Both containers are on the same **network**. WordPress finds MySQL by its name: `db`.
- MySQL writes its data to `/var/lib/mysql` inside the container.
  The **volume** is mounted there, so the data lives outside the container.
- Settings like the database name, user and password are given with **environment variables**.

## How to run

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Open http://localhost:8080 in your browser.
If you see "Error establishing a database connection", wait 20-30 seconds.
MySQL needs some time to get ready.

```bash
terraform destroy   # deletes everything, including the volume!
```

## ⚠️ Note

The passwords are written directly in the code for now. This is not safe.
In the next project, I will move them into **variables**.

## What I learned

- **Network:** Containers on the same Docker network can find each other by name (DNS).
- **Volume:** Data in a volume stays, even when the container is deleted. But `terraform destroy` deletes the volume too.
- **Environment variables:** The format is `"NAME=value"`, with no spaces.
- **Interpolation:** `"${docker_container.db_container.name}"` puts a reference inside a string.
  Terraform can see the dependency, so it creates MySQL before WordPress.
- **Order in the file does not matter:** Terraform reads all blocks and decides the order from the references.
- **Terraform only knows its own resources:** It manages only what is in its state file (`terraform state list`).
  A container created by hand can block Terraform, for example when it tries to delete an image.
- **"Container is running" is not the same as "the app is ready".**
- **Protecting data:** Use separate environments, `prevent_destroy`, separate state, and backups.