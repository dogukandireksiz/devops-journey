# 09 - Terraform + AWS: My first EC2 server

This project creates my first **virtual server (EC2)** in AWS, inside the network from project `08`.
Then I connect to it with **SSH**.

## 🗺️ The big picture

```mermaid
flowchart TB
    Laptop["💻 My laptop<br/>private key 🔑"]
    Internet(("🌍 Internet"))
    IGW["🚪 Internet Gateway<br/>NAT: 13.49.x.x ↔ 10.0.1.x"]

    subgraph VPC["🏘️ VPC: 10.0.0.0/16 (from project 08)"]
        subgraph SUBNET["🏢 Public subnet: 10.0.1.0/24"]
            SG["💂 Security Group<br/>in: SSH (22) only from my IP /32<br/>in: HTTP (80) from everyone<br/>out: everything"]
            EC2["🖥️ EC2: Ubuntu 24.04, t3.micro<br/>private IP: 10.0.1.x<br/>public key 🔒"]
            SG --- EC2
        end
    end

    Laptop -- "ssh -i key ubuntu@public-ip" --> Internet
    Internet <--> IGW
    IGW <--> SG
```

## 📚 Lesson notes

### EC2 concepts (with Docker in mind)

| EC2 | Docker | In the site | What is it? |
|---|---|---|---|
| **AMI** | Image | The plan of a flat | Operating system template (Ubuntu) |
| **Instance** | Container | The flat itself | A running virtual machine |
| **Instance type** | CPU/RAM limits | The size of the flat | `t3.micro`: 2 vCPU, 1 GB RAM |
| **Key pair** | - | The key of the flat 🔑 | SSH login without a password |
| **Security Group** | Port mapping | A guard at the door 💂 | Firewall for the server |
| **Public IP** | `localhost:8080` | The door number from outside | Address on the internet |

### 🔑 SSH key pair

| Key | Where? | Like |
|---|---|---|
| **Public key** (`.pub`) | Uploaded to AWS, put on the server | A lock 🔒: anyone can see it |
| **Private key** | **Only on my laptop** | The key 🔑: never shared, never in Git |

```bash
ssh-keygen -t ed25519 -f ~/.ssh/devops-journey -C "devops-journey"
```

On the first connection, SSH asks to trust the server's fingerprint and saves it in `~/.ssh/known_hosts`.
If the fingerprint changes later, SSH warns me (protection against *man-in-the-middle* attacks).

### 💂 Security Group rules

| Direction | Rule | Why? |
|---|---|---|
| **Inbound** | TCP port 22 (SSH), only from `my_ip/32` | Only I can connect. `/32` = exactly one IP address |
| **Outbound** | All traffic to `0.0.0.0/0` | The server can download updates (`apt`) |

Never open SSH to `0.0.0.0/0` (the whole internet)!

**Home IPs can change.** If SSH stops working, check `curl ifconfig.me` and update `terraform.tfvars`.

### 🌍 Two IPs, one server (NAT)

| | My home | My server |
|---|---|---|
| Private IP | `192.168.1.x` (from my modem) | `10.0.1.x` (from my subnet) |
| Public IP | From my internet provider | From AWS |
| Who translates? | My **modem** | The **Internet Gateway** |

The server only knows its private IP. The Internet Gateway translates between the public and the private IP.
This is **NAT** (Network Address Translation).

### 🔍 Resource vs data source

| | Resource | Data source |
|---|---|---|
| What does it do? | **Creates** something 🔨 | **Finds / reads** something that exists 🔍 |
| Example | `resource "aws_instance"` | `data "aws_vpc"` |
| Reference | `aws_instance.server.id` | `data.aws_vpc.main.id` |

Projects `08` and `09` have separate states. `09` cannot reference resources from `08`,
so it **finds** the VPC and the subnet by their `Name` tags with data sources.

### 💿 Finding the AMI safely

AMI IDs change often and are different in every region, so I never write them by hand.
A data source finds the newest Ubuntu 24.04 image:

- `most_recent = true` → pick the newest
- `owners = ["099720109477"]` → **only trust Canonical** (the company behind Ubuntu).
  Anyone can publish an AMI called "ubuntu", even with malware inside!
- `filter` on the name: `ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*`

⚠️ A newer AMI can make `plan` want to **replace** the server (`-/+`). That is the price of "always the newest".

## 🧱 What it creates

| Type | Address | What? |
|---|---|---|
| data | `data.aws_vpc.main` | Finds the VPC from project `08` |
| data | `data.aws_subnet.public` | Finds the public subnet |
| data | `data.aws_ami.ubuntu` | Finds the newest Ubuntu 24.04 AMI |
| resource | `aws_key_pair` | Uploads my public key (`file("~/.ssh/devops-journey.pub")`) |
| resource | `aws_security_group.main` | The guard 💂 |
| resource | `aws_vpc_security_group_ingress_rule` | SSH from my IP |
| resource | `aws_vpc_security_group_egress_rule` | All outbound traffic |
| resource | `aws_instance.server` | The server 🖥️ |
| resource | `aws_vpc_security_group_ingress_rule.http` | HTTP (port 80) from everyone |

**Outputs:** `server_public_ip` (for SSH) and `website_url` (open it in a browser)

**Variable:** `my_ip`: my public IP with `/32`. Its value is in `terraform.tfvars` (not in Git).
See `terraform.tfvars.example`.

## 🚀 How to run

Requirements: project `08` (the VPC) must exist, and an SSH key in `~/.ssh/devops-journey`.

```bash
aws login
curl ifconfig.me                  # my public IP → terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

terraform init
terraform plan
terraform apply

ssh -i ~/.ssh/devops-journey ubuntu@<server_public_ip>
```

## 🌐 Web server with `user_data`

The server installs **nginx** and writes its own web page **by itself**, on the first boot.
No manual SSH work is needed.

```hcl
user_data = <<-EOF
  #!/bin/bash
  apt-get update && apt-get install -y nginx
  echo "<h1>Hello World</h1>" > /var/www/html/index.html
EOF

user_data_replace_on_change = true
```

- **`user_data`** is a script that runs **only on the first boot** of the server.
  (Like MySQL environment variables in project `02`: they are read only on the first start.)
- **`<<-EOF ... EOF`** (heredoc) writes a multi-line string in HCL.
- **`&&`**: the second command runs only if the first one succeeds.
- **`-y`**: "answer yes", because nobody is at the keyboard when the script runs.
- **`user_data_replace_on_change = true`**: if the script changes, Terraform **replaces** the server (`-/+`),
  so the new script runs. Without it, a running server never sees the new script.

### 💂 Why is port 80 open to everyone, but SSH is not?

| Port | Gives | Who? |
|---|---|---|
| 22 (SSH) | Full control of the server 🔧 | Only me (`/32`) |
| 80 (HTTP) | Only the web page 👀 | Everyone (`0.0.0.0/0`) |

Like a shop: the shop window is open to everyone, but only the owner has the key to the storeroom. 🏪🔑
Least privilege means **each door gets only the access it needs**.

### ⏳ Running is not the same as ready

After `apply`, the script still works in the background for 1-2 minutes.
I opened the page too early and saw "Welcome to nginx" (nginx was installed, but my page was not written yet).
After a refresh, I saw "Hello World".

If the page does not work, check on the server:

```bash
cloud-init status                                  # done?
ls -la /var/www/html/
sudo tail -20 /var/log/cloud-init-output.log      # the script's logs
```

### ⚠️ The limit of `user_data`

To change the page, I must **replace the whole server**, because `user_data` runs only once.
A configuration management tool like **Ansible** can change a running server without replacing it.
That is the next phase!

## 💰 Cost

The EC2 server is paid **per hour** (from my Free plan credits).
**When I finish a session, I run `terraform destroy`.** The next `terraform apply` brings everything back. 🔄

## 💡 What I learned

- **Everything comes together:** VPC, subnet, gateway, route table, public IP, Security Group, key pair and AMI.
- **`file()`** reads a file's content. Use the `.pub` file, never the private key!
- **`vpc_security_group_ids` is a list** (`[...]`), because a server can have many Security Groups.
- **`.id` vs `.public_ip`:** The ID is like a title deed (`i-...`), the public IP is the address.
- **Read every plan:** An unexpected `1 to destroy` showed that changing a resource label means "delete and create".
- **`moved` block:** Renames a resource in the state without destroying it:
```hcl
  moved {
    from = aws_key_pair.old_name
    to   = aws_key_pair.new_name
  }
```
- **Check the region in the console:** AWS shows resources per region.
- **Manage with Terraform, not the console:** Stopping a server in the console creates drift.
- **`user_data`** configures a server automatically on the first boot.
- **Clean up test outputs:** Outputs should show what the user needs (`website_url`), not debugging values.
- **Output names cannot have spaces:** use `website_url`, not `address of site`.