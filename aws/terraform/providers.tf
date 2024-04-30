terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  region  = "AWS_REGION"
  profile = "AWS_PROFILE"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "KUBECONFIG_CONTEXT"
}
