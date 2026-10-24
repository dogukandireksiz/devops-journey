terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}


resource "kubernetes_namespace_v1" "nginx"{
    metadata{
        name = "nginx"
    }
}

locals {
  nginx_port = 80
}

resource "kubernetes_deployment_v1" "nginx" {
  metadata {
    name = "nginx"
    namespace = kubernetes_namespace_v1.nginx.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          image = "nginx"
          name  = "nginx-example"
          port{
            container_port = local.nginx_port
          }
        }
      }
    }
  }
}


resource "kubernetes_service_v1" "nginx"{
    metadata{
        name = "nginx"
        namespace = kubernetes_namespace_v1.nginx.metadata[0].name
    }
    spec {
        selector = {app = "nginx"}
        type = "NodePort"
        port{
            port=80
            target_port=local.nginx_port
            node_port=30000
        }
    }
} 