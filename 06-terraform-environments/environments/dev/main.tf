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
    environment = "dev"
    replicas = 1
    node_port = 30001

}
