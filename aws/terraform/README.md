# AWS Terraform Modules

These Terraform modules provide partial automation of the Kubernetes cluster setup, as outlined in the Privacy Dynamics [Self-Hosted Install](https://www.privacydynamics.io/docs/enterprise/self-hosted-install) documentation.

## General Requirements

### Provider Values

See the documentation for the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and the [Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) for full details of possible values in `providers.tf`.

- `region` = the region of the EKS cluster
- `profile` = the AWS CLI profile for the EKS cluster
- `config_path` = the file path to your local Kubeconfig file, default is `~/.kube/config`
- `config_context` = the name of the context for your EKS cluster[^1]

[^1]: Run `kubectl config get-contexts` to see a list of all contexts in your kubeconfig file; if `config_context` is not set in `providers.tf`, it will default to your current Kubernetes context, as long as one is set in your kubeconfig file

### Required Tools

These modules depend on other utilities for access to remote resources. The following are required:

- [AWS CLI](https://aws.amazon.com/cli/), logged in to an account with access to the EKS cluster
- [kubectl](https://kubernetes.io/docs/reference/kubectl/), with a [properly configured kubeconfig file](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html), allowing access to the EKS cluster

## IAMServiceAccounts

This module creates IAM Roles and Policies, as well as Kubernetes ServiceAccounts, to allow certain workloads access to AWS resources, such as Route 53 and S3. See the [module README](modules/iamserviceaccounts/README.md) for details.

### Required Values for IAMServiceAccounts

The following values must be set when invoking this module from `main.tf`. See the [module README](modules/iamserviceaccounts/README.md) for the full list of possible variables.

- `dns_zone_name` = the subdomain for a new DNS zone, the module will attempt to create this DNS Zone in Route 53
- `eks_cluster_name` = the name of an existing EKS cluster
- `s3_bucket` = the name for a new S3 Bucket to hold application database backups; the module will attempt to create this Bucket[^2]

[^2]: Remember that S3 Bucket names must be globally unique

## Elastic File System Module

This module creates a Security Group in your cluster's VPC to allow NFS traffic on port 2049. It then creates an EFS file system and Mount Targets for that file system in each subnet associated with your cluster. Finally, it creates an EFS-backed StorageClass on your cluster. See the [module README](modules/elastic-file-system/README.md) for details. Please note that the EFS CSI Driver EKS Add-on should be installed before running this module. See the [Privacy Dynamics documentation](https://www.privacydynamics.io/docs/enterprise/kubernetes) for more information about EKS add-on installation.

### Required Values for Elastic File System

The following value must be set when invoking this module from `main.tf`.

- `eks_cluster_name` - the name of your EKS cluster
