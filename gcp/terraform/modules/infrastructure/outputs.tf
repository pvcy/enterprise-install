output "cloud_bucket_name" {
  description = "Name of the Google Cloud Storage bucket"
  value       = google_storage_bucket.cnpg_backups.name
}

output "dns_zone_name" {
  description = "Name of the Google Cloud DNS zone"
  value       = google_dns_managed_zone.this.name
}
