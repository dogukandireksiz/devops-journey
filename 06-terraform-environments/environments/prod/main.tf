terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.4"
    }
  }
  required_version = ">= 1.6"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}


module "nginx"{
    source = "../../modules/nginx"
    environment = "prod"
    replicas = 3
    node_port = 30002

}
