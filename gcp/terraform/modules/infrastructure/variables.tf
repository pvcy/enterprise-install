variable "dns_zone" {
  type = object({
    name      = string
    subdomain = string
  })
  description = "Name and subdomain of a Cloud DNS zone"
}

variable "location" {
  type        = string
  description = "Region for the GKE cluster"
}

variable "storage_bucket" {
  type        = string
  description = "Cloud Storage bucket to hold backups of the application database"
}
