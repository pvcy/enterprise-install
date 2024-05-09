# Workload Identity Module

This module assigns IAM Principals corresponding to Kubernetes Service Accounts to Google Cloud resources, to allow certain workloads access to GCP resources, such as Cloud DNS and Cloud Storage. These are intended for Helm deployments that will be installed with Replicated.

## Authentication

If running these modules from a workstation, Terraform recommends authenticating to Google Cloud with User Application Default Credentials. See [the Google Provider's documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication) for details.

## Resources

The Terraform files provided here will create the following resources:

- A Project-level IAM Policy Binding granting DNS Administrator access to the external-dns and cert-manager ServiceAccounts
- A Bucket-level IAM Policy Binding granting Storage Administrator access to the postgres ServiceAccount

As long as Workload Identity has been activated for the cluster and the GKE Metadata Server is running on the nodes, these ServiceAccounts should be able to access the needed cloud resources. No annotation or label is required.

## Variables

The following variables must be set in order for this module to run correctly. Several variables have default values that should work in most cases, but can be overriden by defining a value when invoking this module from the parent `main.tf` file. Variables without a default value must have a value supplied from the parent `main.tf` in order for this module to run successfully.

| Variable                    | Description                                  | Default      |
|-----------------------------|----------------------------------------------|--------------|
| `cert_manager_sa.name`      | name of the cert-manager ServiceAccount      | cert-manager |
| `cert_manager_sa.namespace` | namespace of the cert-manager ServiceAccount | cert-manager |
| `dns_zone_name`             | the subdomain for the DNS zone               |              |
| `external_dns_sa.name`      | name of the external-dns ServiceAccount      | external-dns |
| `external_dns_sa.namespace` | namespace of the external-dns ServiceAccount | external-dns |
| `postgres_sa.name`          | name of the postgres ServiceAccount          | postgres     |
| `postgres_sa.namespace`     | namespace of the postgres ServiceAccount     | pvcy         |
| `storage_bucket_name`       | the name for Cloud Storage                   |              |
