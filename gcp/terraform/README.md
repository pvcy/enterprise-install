# GCP Terraform Modules

These Terraform modules provide partial automation of the Kubernetes cluster setup, as outlined in the Privacy Dynamics [Self-Hosted Install](https://www.privacydynamics.io/docs/enterprise/self-hosted-install) documentation.

## General Requirements

### Provider Values

See the documentation for the [Google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs) and the [Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) for full details of possible values in `providers.tf`.

- `project` = the Google Cloud Project
- `region` = the region of the GKE cluster
- `config_path` = the file path to your local Kubeconfig file, default is `~/.kube/config`
- `config_context` = the name of the context for your GKE cluster[^1]

[^1]: Run `kubectl config get-contexts` to see a list of all contexts in your kubeconfig file; if `config_context` is not set in `providers.tf`, it will default to your current Kubernetes context, as long as one is set in your kubeconfig file

### Required Tools

These modules depend on other utilities for access to remote resources. The following are required:

- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install), logged in to an account with access to the GKE cluster

## Infrastructure

This module creates a Cloud DNS zone (for internet access to the Privacy Dynamics application) and a Cloud Storage bucket (for backups of the application database).

### Required Values for Infrastructure

The following values must be set when invoking this module from `main.tf`.

- `dns_zone.name` = Name for the Cloud DNS zone
- `dns_zone.subdomain` = the subdomain for a new DNS zone, the module will attempt to create this DNS Zone in Cloud DNS
- `storage_bucket` = the name for a new Cloud Storage Bucket to hold application database backups; the module will attempt to create this Bucket[^1]
- `location` = Google Cloud Region of the GKE cluster

[^1]: Remember that Cloud Storage Bucket names must be globally unique

## Workload Identity

This module assigns IAM Principals corresponding to Kubernetes Service Accounts to Google Cloud resources, to allow certain workloads access to GCP resources, such as Cloud DNS and Cloud Storage. See the [module README](modules/workload_identity/README.md) for details.

### Required Values for Workload Identity

The following values must be set when invoking this module from `main.tf`. See the [module README](modules/workload_identity/README.md) for the full list of possible variables.

- `dns_zone_name` = Name of the Cloud DNS zone created by the Infrastructure module
- `storage_bucket_name` = Name of the Cloud Storage bucket created by the Infrastructure module
