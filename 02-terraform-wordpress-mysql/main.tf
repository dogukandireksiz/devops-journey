terraform{
    required_providers {
        docker = {
            source = "kreuzwerker/docker"
        }
    }
}

resource "docker_network" "network"{
    name = "wordpress-db-network"
}

resource "docker_volume" "volume"{
    name = "mysql-volume"
} 

resource "docker_container" "db_container"{
    name = "db"
    image = docker_image.mysql_image.image_id
    networks_advanced {
        name = docker_network.network.name
    }
    volumes {
        volume_name = docker_volume.volume.name
        container_path = "/var/lib/mysql"
    }
    env = ["MYSQL_ROOT_PASSWORD=1", "MYSQL_DATABASE=mysql-db", "MYSQL_USER=user" , "MYSQL_PASSWORD=1"]
}

resource "docker_image" "mysql_image"{
    name = "mysql"
}

resource "docker_image" "wordpress_image"{
    name = "wordpress"
}

resource "docker_container" "wordpress_container"{
    name = "wordpress_container"
    image = docker_image.wordpress_image.image_id
    networks_advanced {
        name = docker_network.network.name
    }
    ports {
        internal = 80
        external = 8080
    }
    env = ["WORDPRESS_DB_HOST=${docker_container.db_container.name}", "WORDPRESS_DB_NAME=mysql-db", "WORDPRESS_DB_USER=user" , "WORDPRESS_DB_PASSWORD=1"]
}