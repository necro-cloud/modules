terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }

  backend "kubernetes" {
    secret_suffix = "deployment"
  }
}

provider "kubernetes" {
}

provider "helm" {
}
