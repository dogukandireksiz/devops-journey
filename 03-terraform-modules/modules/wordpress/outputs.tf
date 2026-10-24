output "wordpress_url"{
    description = "URL of the wordpress"
    value = "http://localhost:${docker_container.wordpress_container.ports[0].external}"
}