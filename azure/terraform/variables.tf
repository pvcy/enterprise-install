variable "aks_cluster_information" {
  type = object({
    location        = string
    resource_group  = string
    dns_zone_name   = string
    storage_account = string
    oidc_issuer_url = string
  })
  default = {
    location        = "AZURE_LOCATION"
    resource_group  = "AKS-PVCY-GROUP"
    dns_zone_name   = "PVCY.CUSTOMER.COM"
    storage_account = "PVCYBACKUPS"
    oidc_issuer_url = "https://LOCATION.oic.prod-aks.azure.com/SUBSCRIPTION_ID/TENANT_ID/"
  }
}

variable "external-dns" {
    type = object({
    namespace       = string
    serviceaccount  = string
  })
  default = {
    namespace       = "external-dns"
    serviceaccount  = "external-dns"
  }
}

variable "cert-manager" {
  type = object({
    namespace       = string
    serviceaccount  = string
  })
  default = {
    namespace       = "cert-manager"
    serviceaccount  = "cert-manager"
  }
}

variable "postgres" {
  type = object({
    namespace       = string
    serviceaccount  = string
  })
  default = {
    namespace       = "pvcy"
    serviceaccount  = "postgres"
  }
}
