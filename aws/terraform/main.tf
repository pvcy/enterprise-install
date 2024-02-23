module "iamserviceaccounts" {
  source            = "./modules/iamserviceaccounts"
  dns_zone_name     = "PVCY.CUSTOMER.COM"
  eks_cluster_name  = "EKS_NAME"
  oidc_provider_url = "https://oidc.eks.REGION.amazonaws.com/id/ABC123"
  s3_bucket         = "BACKUPS_S3_BUCKET"
}
