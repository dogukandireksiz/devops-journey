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


module "nginx"{
    source = "../../modules/nginx"
    environment = "prod"
    replicas = 3
    node_port = 30002

}
