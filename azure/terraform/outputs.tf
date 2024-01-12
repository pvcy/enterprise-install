output "managed_identity_client_id_blob_storage_contributor" {
  description = "Client ID of the blob-storage-contributor Managed Identity"
  value = azurerm_user_assigned_identity.blob-storage-contributor.client_id
}

output "managed_identity_client_id_dns_contributor" {
  description = "Client ID of dns-contributor Managed Identity"
  value = azurerm_user_assigned_identity.dns_contributor_identity.client_id  
}

output "subscription_id" {
  description = "Your Azure Subscription ID"
  value = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "Your Azure Tenant ID"
  value = data.azurerm_subscription.current.tenant_id
}
