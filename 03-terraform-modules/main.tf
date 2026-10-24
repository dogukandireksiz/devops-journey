terraform{
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
        }
    }
}

module "blog"{
    source = "./modules/wordpress"
    site_name = "blog"
    wordpress_port = 8080
    db_name = "wordpress"
    db_password = var.db_password
    db_root_password = var.db_root_password
}

module "shop"{
    source = "./modules/wordpress"
    site_name = "shop"
    wordpress_port = 9090
    db_name = "wordpress"
    db_password = var.db_password
    db_root_password = var.db_root_password
}

module "portfolio"{
    source = "./modules/wordpress"
    site_name = "portfolio"
    wordpress_port = 7070
    db_name = "wordpress"
    db_password = var.db_password
    db_root_password = var.db_root_password
}