terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

provider "docker" {
  # Configuration options
}

resource "docker_image" "image_nginx" {
  name = "nginx"

}

resource "docker_container" "container_nginx" {
  name  = "nginx-container"
  image = docker_image.image_nginx.image_id
  ports {
    internal = 80
    external = 8080
  }

}

