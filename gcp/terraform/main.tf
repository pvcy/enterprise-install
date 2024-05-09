module "create_infrastructure" {
  source = "./modules/infrastructure"
  dns_zone = {
    name      = var.dns_zone.name
    subdomain = var.dns_zone.subdomain
  }
  storage_bucket = var.storage_bucket
  location       = var.location
}

module "create_workload_identities" {
  source              = "./modules/workload_identity"
  dns_zone_name       = module.create_infrastructure.dns_zone_name
  storage_bucket_name = module.create_infrastructure.cloud_bucket_name
}
