data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "aks_resource_group" {
  name                  = var.aks_cluster_information.resource_group
}

resource "azurerm_dns_zone" "pvcy_zone" {
  name                  = var.aks_cluster_information.dns_zone_name
  resource_group_name   = data.azurerm_resource_group.aks_resource_group.name
}

resource "azurerm_storage_account" "backups" {
  name                      = var.aks_cluster_information.storage_account
  resource_group_name       = data.azurerm_resource_group.aks_resource_group.name
  location                  = var.aks_cluster_information.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_user_assigned_identity" "dns_contributor_identity" {
  location              = var.aks_cluster_information.location
  name                  = "dns-contributor"
  resource_group_name   = data.azurerm_resource_group.aks_resource_group.name
}

resource "azurerm_user_assigned_identity" "blob-storage-contributor" {
  location              = var.aks_cluster_information.location
  name                  = "blob-storage-contributor"
  resource_group_name   = data.azurerm_resource_group.aks_resource_group.name
}

resource "azurerm_role_assignment" "dns_contributor" {
  scope                 = azurerm_dns_zone.pvcy_zone.id
  role_definition_name  = "DNS Zone Contributor"
  principal_id          = azurerm_user_assigned_identity.dns_contributor_identity.principal_id
}

resource "azurerm_role_assignment" "dns_resource_group_reader" {
  scope                 = data.azurerm_resource_group.aks_resource_group.id
  role_definition_name  = "Reader"
  principal_id          = azurerm_user_assigned_identity.dns_contributor_identity.principal_id
}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                 = azurerm_storage_account.backups.id
  role_definition_name  = "Storage Blob Data Contributor"
  principal_id          = azurerm_user_assigned_identity.blob-storage-contributor.principal_id
}

resource "azurerm_federated_identity_credential" "externaldns_credential" {
  name                  = var.external-dns.serviceaccount
  resource_group_name   = data.azurerm_resource_group.aks_resource_group.name
  audience              = ["api://AzureADTokenExchange"]
  issuer                = var.aks_cluster_information.oidc_issuer_url
  parent_id             = azurerm_user_assigned_identity.dns_contributor_identity.id
  subject               = "system:serviceaccount:${var.external-dns.namespace}:${var.external-dns.serviceaccount}"
}

resource "azurerm_federated_identity_credential" "certmanager_credential" {
  name                  = var.cert-manager.serviceaccount
  resource_group_name   = data.azurerm_resource_group.aks_resource_group.name
  audience              = ["api://AzureADTokenExchange"]
  issuer                = var.aks_cluster_information.oidc_issuer_url
  parent_id             = azurerm_user_assigned_identity.dns_contributor_identity.id
  subject               = "system:serviceaccount:${var.cert-manager.namespace}:${var.cert-manager.serviceaccount}"
}

resource "azurerm_federated_identity_credential" "postgres_credential" {
  name                  = var.postgres.serviceaccount
  resource_group_name   = data.azurerm_resource_group.aks_resource_group.name
  audience              = ["api://AzureADTokenExchange"]
  issuer                = var.aks_cluster_information.oidc_issuer_url
  parent_id             = azurerm_user_assigned_identity.blob-storage-contributor.id
  subject               = "system:serviceaccount:${var.postgres.namespace}:${var.postgres.serviceaccount}"
}
