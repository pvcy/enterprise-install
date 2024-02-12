variable "cluster_name" {
  type    = string
  default = "EKS_NAME"
}

module "iamserviceaccounts" {
  source            = "./modules/iamserviceaccounts"
  dns_zone_name     = "PVCY.CUSTOMER.COM"
  eks_cluster_name  = var.cluster_name
  oidc_provider_url = "https://oidc.eks.REGION.amazonaws.com/id/ABC123"
  s3_bucket         = "BACKUPS_S3_BUCKET"
}

module "elastic-file-system" {
  source = "./modules/elastic-file-system"
  eks_cluster_name = var.cluster_name
}
