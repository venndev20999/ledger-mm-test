terraform {
  required_version = ">= 1.5.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26"
    }
  }
}

provider "kubernetes" {
  config_path = "/Users/vennpham/.kube/config" # my homelabs development cluster
}
