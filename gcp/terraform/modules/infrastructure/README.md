# Infrastructure Module

This module creates a Cloud DNS zone (for internet access to the Privacy Dynamics application) and a Cloud Storage bucket (for backups of the application database). The Workload Identity module will later link these resources to Kubernetes ServiceAccounts.

## Resources

The Terraform files provided here will create the following resources:

- A Cloud DNS zone
- A Cloud Storage bucket in the same region as the GKE cluster, with uniform bucket-level access enabled

## Variables

The following variables must be set in order for this module to run correctly. 

| Variable             | Description                            |
|----------------------|----------------------------------------|
| `dns_zone.name`      | name for the Cloud DNS zone            |
| `dns_zone.subdomain` | subdomain for the DNS zone             |
| `location`           | Google Cloud Region of the GKE cluster |
| `storage_bucket`     | name for a new Cloud Storage Bucket    |

## Outputs

After applying this Terraform module, the following outputs will be shown:

- `cloud_bucket_name` = the name of the Google Cloud Storage bucket created by this module
- `dns_zone_name` = the name of the Google Cloud DNS zone created by this module
