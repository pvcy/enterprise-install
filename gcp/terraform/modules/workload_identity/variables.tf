variable "cert_manager_sa" {
  type = object({
    name      = string
    namespace = string
  })
  description = "Name and namespace of the cert-manager ServiceAccount"
  default = {
    name      = "cert-manager"
    namespace = "cert-manager"
  }
}

variable "dns_zone_name" {
  type        = string
  description = "Name of a Cloud DNS Zone"
}

variable "external_dns_sa" {
  type = object({
    name      = string
    namespace = string
  })
  description = "Name and namespace of the external-dns ServiceAccount"
  default = {
    name      = "external-dns"
    namespace = "external-dns"
  }
}

variable "postgres_sa" {
  type = object({
    name      = string
    namespace = string
  })
  description = "Name and namespace of the postgres ServiceAccount"
  default = {
    name      = "postgres"
    namespace = "pvcy"
  }
}

variable "storage_bucket_name" {
  type        = string
  description = "Cloud Storage bucket to hold backups of the application database"
}
