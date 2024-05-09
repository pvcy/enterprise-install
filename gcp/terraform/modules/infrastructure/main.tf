resource "google_dns_managed_zone" "this" {
  dns_name = var.dns_zone.subdomain
  name     = var.dns_zone.name
}

resource "google_storage_bucket" "cnpg_backups" {
  name                        = var.storage_bucket
  location                    = var.location
  uniform_bucket_level_access = true
}

resource "kubernetes_storage_class" "filestore" {
  metadata {
    name = "filestore-sc"
  }
  parameters = {
    tier    = "standard"
    network = "default"
  }
  storage_provisioner    = "filestore.csi.storage.gke.io"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
}
