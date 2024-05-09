variable "dns_zone" {
  type = object({
    name      = string
    subdomain = string
  })
  description = "Name and subdomain of a Cloud DNS zone"
  default = {
    name      = "DNS_ZONE_NAME"
    subdomain = "PVCY.CUSTOMER.COM."
  }
}

variable "google_project_name" {
  type        = string
  description = "Name of the Google Project"
  default     = "GOOGLE_PROJECT"
}

variable "kubernetes_config_path" {
  type = string
  description = "Path to kubeconfig file"
  default = "~/.kube/config"
}

variable "kubernetes_context" {
  type = string
  description = "Kubernetes context for cluster"
  default = "KUBERNETES_CONTEXT"
}

variable "location" {
  type        = string
  description = "Region for the GKE cluster"
  default     = "REGION"
}

variable "storage_bucket" {
  type        = string
  description = "Cloud Storage bucket to hold backups of the application database"
  default     = "STORAGE_BUCKET_NAME"
}
