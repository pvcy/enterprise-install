# Azure Terraform Configuration Files

## Resources

The Terraform files provided here will create the following resources:

- An Azure DNS Zone for Privacy Dynamics software
- An Azure Storage Account for backups of the Privacy Dynamics application database
- Two Managed Identities, one for DNS access and the other for access to the Storage Account
- Role assignments related to the Managed Identities
- Three Federated Identity Credentials, each linked to one of the two Managed Identities

The Federated Identity Credentials are linked to Kubernetes ServiceAccount resources through an Annotation referencing the associated Managed Identity's Client ID. This Annotation is created through the applicable Helm charts, which can be deployed via Replicated.

## Variables

The following information needs to be set in the `var.aks_cluster_information` variable in the `variables.tf` file in order for these Terraform files to run correctly:

- `location` = the Azure location (region) for the AKS cluster
- `resource_group` = the Resource Group containing the AKS cluster
- `dns_zone_name` = the subdomain for the DNS zone to be created (e.g. `pvcy.example.com`)
- `storage_account` = the name for the Storage Account to be created
- `oidc_issuer_url` = the URL of the OpenID Connect (OIDC) Issuer; see the [Azure documentation](https://learn.microsoft.com/en-us/azure/aks/use-oidc-issuer) for details on finding or creating your cluster's OIDC Issuer URL

## Outputs

After applying these Terraform configuration files, the following outputs will be shown:

- Client ID of the `blob-storage-contributor` Managed Identity = the value for the "Storage Managed Identity Client ID" field during Privacy Dynamics software installation
- Client ID of the `dns-contributor` Managed Identity = the value for the "DNS Managed Identity ClientID" field during Privacy Dynamics software installation, if opting to include ExternalDNS or cert-manager
- Azure Subscription ID = required during Privacy Dynamics software installation, if opting to include ExternalDNS or cert-manager 
- Azure Tenant ID = also required during Privacy Dynamics software installation, if opting to include ExternalDNS or cert-manager
