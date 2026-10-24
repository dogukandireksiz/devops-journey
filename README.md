# 03 - Terraform Modules: Two WordPress Sites

This project turns the WordPress + MySQL setup from project `02` into a **module**.
Then it uses the same module **twice** to create two separate WordPress sites: `blog` and `shop`.

One code, two sites. 🚀

## What is a module?

In Terraform, **every folder with `.tf` files is a module**.

- **Root module:** The folder where you run `terraform` commands (here: `03-terraform-modules/`).
- **Child module:** A module that the root module calls (here: `modules/wordpress/`).

A module is like a **function** in programming:

| Terraform | Programming |
|---|---|
| Module | Function |
| `module` block | Function call |
| Variable | Parameter |
| Output | Return value |

## Folder structure

```
03-terraform-modules/
├── main.tf                    # Root: calls the module two times
├── variables.tf               # Root: password variables
├── outputs.tf                 # Root: URLs of the two sites
├── terraform.tfvars.example   # Example values (copy to terraform.tfvars)
└── modules/
    └── wordpress/
        ├── main.tf            # Network, volume, images, containers
        ├── variables.tf       # Module parameters
        └── outputs.tf         # Module return value: wordpress_url
```

## What it creates

Each site gets its own resources. The `site_name` variable is added to the start of every Docker name (a **prefix**), so the names never clash.

| Resource | Name pattern | `blog` | `shop` |
|---|---|---|---|
| Network | `<site_name>-network` | `blog-network` | `shop-network` |
| Volume | `<site_name>-mysql-data` | `blog-mysql-data` | `shop-mysql-data` |
| MySQL container | `<site_name>-db` | `blog-db` | `shop-db` |
| WordPress container | `<site_name>-wordpress-container` | `blog-wordpress-container` | `shop-wordpress-container` |
| Port | `wordpress_port` | `8080` | `9090` |

The two sites share the same `mysql` and `wordpress` **images** (one class, many objects).

In total: **2 modules × 6 resources = 12 resources.**

## Module variables

| Name | Type | Default | Sensitive | Description |
|---|---|---|---|---|
| `site_name` | string | - | No | Unique name of the site, used as a prefix for all Docker names |
| `wordpress_port` | number | `8080` | No | Port on your computer for opening WordPress |
| `db_name` | string | - | No | Name of the MySQL database for WordPress |
| `db_user` | string | `admin` | No | Normal (not root) MySQL user for WordPress |
| `db_password` | string | - | Yes | Password for `db_user` |
| `db_root_password` | string | - | Yes | Password for the MySQL root user |

Variables with no default are **required**: every `module` block must give them a value.

## How values travel

The root module gets the passwords from `terraform.tfvars` and passes them to the module:

```
terraform.tfvars
     ↓
root variable          (var.db_password in the root)
     ↓
module block           db_password = var.db_password
     ↓
module variable        (var.db_password in the module)
     ↓
environment variable   "MYSQL_PASSWORD=..."
     ↓
MySQL
```

## Outputs

| Name | Value |
|---|---|
| `blog_url` | `http://localhost:8080` |
| `shop_url` | `http://localhost:9090` |

The module returns `wordpress_url`. The root reads it with `module.<name>.wordpress_url` and shows it on the screen.

## How to run

1. Copy the example file and write your own passwords:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Run Terraform:

```bash
terraform init      # also installs the module
terraform validate
terraform plan      # Plan: 12 to add
terraform apply
```

3. Wait about 1 minute (two MySQL servers start at the same time), then open `blog_url` and `shop_url`.

```bash
terraform destroy   # deletes everything, including both volumes!
```

The images are not deleted on destroy (`keep_locally = true`), so the next `apply` is faster.

## How to add a new site

Add one more `module` block to `main.tf` with a new `site_name` and a new port. That's all: Terraform creates 6 new resources.

## What I learned

**Modules**
- **A module is a function:** Variables are parameters, outputs are return values.
- **`source` should be a relative path** (`./modules/wordpress`), so the code works on every computer.
- **Required arguments:** Every module variable without a default must be given in the `module` block.
- **`terraform.tfvars` talks only to the root module.** To give a value to a module, pass it in the `module` block.
- **Module outputs are not printed.** The root must read them (`module.blog.wordpress_url`) and print them with its own outputs.
- **Resource addresses inside a module** look like `module.blog.docker_volume.volume`.
- **File names don't matter to Terraform:** It reads all `.tf` files in a folder. `main.tf`, `variables.tf` and `outputs.tf` are just a habit for humans.

**Naming and clashes**
- **Prefix:** One variable (`site_name`) makes all names unique.
- **References pay off:** `WORDPRESS_DB_HOST` uses a reference to the MySQL container's name, so it becomes `blog-db` or `shop-db` automatically.
- **Not all clashes give an error:** Docker can return an existing volume instead of failing. A silent clash is more dangerous than an error.
- **`keep_locally = true`:** Two modules use the same image. Without this, destroying one module can fail because the other still uses the image.

**Debugging**
- **`docker ps` shows only running containers.** Use `docker ps -a` to see stopped ones. `Exited (1)` means it stopped with an error.
- **Read the logs, don't guess:** `docker logs <name>` showed the real problem in seconds.
- **Valid is not the same as correct:** A wrong value (a long sentence as a user name) was valid for Terraform, but MySQL refused it.
- **A failed first start leaves a half-full volume.** MySQL then skips the setup, so the volume must be deleted and created again.