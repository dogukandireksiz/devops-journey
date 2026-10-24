terraform{
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
        }
    }
}

resource "docker_network" "network"{
    name = "${var.site_name}-network"
}

resource "docker_volume" "volume"{
    name = "${var.site_name}-mysql-data"
} 

resource "docker_container" "db_container"{
    name = "${var.site_name}-db"
    image = docker_image.mysql_image.image_id
    networks_advanced {
        name = docker_network.network.name
    }
    volumes {
        volume_name = docker_volume.volume.name
        container_path = "/var/lib/mysql"
    }
    env = ["MYSQL_ROOT_PASSWORD=${var.db_root_password}", "MYSQL_DATABASE=${var.db_name}", "MYSQL_USER=${var.db_user}" , "MYSQL_PASSWORD=${var.db_password}"]
}

resource "docker_image" "mysql_image"{
    name = "mysql"
    keep_locally = true
}

resource "docker_image" "wordpress_image"{
    name = "wordpress"
    keep_locally = true
}

resource "docker_container" "wordpress_container"{
    name = "${var.site_name}-wordpress-container"
    image = docker_image.wordpress_image.image_id
    networks_advanced {
        name = docker_network.network.name
    }
    ports {
        internal = 80
        external = var.wordpress_port
    }
    env = ["WORDPRESS_DB_HOST=${docker_container.db_container.name}", "WORDPRESS_DB_NAME=${var.db_name}", "WORDPRESS_DB_USER=${var.db_user}" , "WORDPRESS_DB_PASSWORD=${var.db_password}"]
}