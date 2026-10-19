# 01 - Terraform + Docker: Nginx

This project does the same job as `docker run -d --name nginx-container -p 8080:80 nginx`,
but with Terraform.

With Terraform, I don't write the steps. I describe **what I want**.
Terraform names the resources, connects them to each other, and creates them.
After that, it keeps track of them in the **state file**. If something changes
outside of Terraform, it can see the difference and fix it.

## What it creates

- `docker_image` → downloads the `nginx` image
- `docker_container` → runs a container from that image, on port `8080`

## Requirements

- Terraform
- Docker

## How to run

```bash
terraform init      # download the Docker provider
terraform validate  # check the code
terraform plan      # see what Terraform will do
terraform apply     # create the resources
terraform destroy   # delete everything
```

After `apply`, open http://localhost:8080 in your browser.

## What I learned

- **Image vs container:** An image is a template (like a class). A container is a running copy of it (like an object).
- **String vs reference:** `"nginx"` is a fixed value. `docker_image.image_nginx.image_id` (no quotes) is a reference to another resource.
- **Read-only attributes:** Some values, like `image_id`, are created by Docker. I can read them, but I can't set them.
- **Dependencies:** Because the container uses a reference to the image, Terraform knows it must create the image first.
- **State and drift:** Terraform remembers what it created. If I delete the container by hand, `terraform plan` shows the difference.
- **`validate` is not enough:** Valid syntax does not mean the code is logically correct.