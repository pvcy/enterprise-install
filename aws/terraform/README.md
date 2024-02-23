# AWS Terraform Modules

These Terraform modules provide partial automation of the Kubernetes cluster setup, as outlined in the Privacy Dynamics [Self-Hosted Install](https://www.privacydynamics.io/docs/enterprise/self-hosted-install) documentation.

## IAMServiceAccounts

This module creates IAM Roles and Policies, as well as Kubernetes ServiceAccounts, to allow certain workloads access to AWS resources, such as Route 53 and S3. See the [module README](modules/iamserviceaccounts/README.md) for details.

### Required Values

The following values must be set when invoking this module from `main.tf`.

#### variables.tf

See the [module README](modules/iamserviceaccounts/README.md) for the full list of possible variables.

- `dns_zone_name` = the subdomain for a new DNS zone, the module will attempt to create this DNS Zone in Route 53
- `eks_cluster_name` = the name of an existing EKS cluster
- `oidc_provider_url` = the URL of an existing OpenID Connect (OIDC) Provider ([see the AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) to enable an OIDC Provider for your cluster)
- `s3_bucket` = the name for a new S3 Bucket to hold application database backups; the module will attempt to create this Bucket, remember that S3 Bucket names must be globally unique

#### providers.tf

See the documentation for the [AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and the [Kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs) for full details of possible values in `providers.tf`.

- `region` = the region of the EKS cluster
- `profile` = the AWS CLI profile for the EKS cluster
- `config_path` = the file path to your local Kubeconfig file, default is `~/.kube/config`
- `config_context` = the name of the context for your EKS cluster[^1]

### Required Tools

This module depend on other utilities for access to remote resources. The following are required:

- [AWS CLI](https://aws.amazon.com/cli/), logged in to an account with access to the EKS cluster
- [kubectl](https://kubernetes.io/docs/reference/kubectl/), with a [properly configured kubeconfig file](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html), allowing access to the EKS cluster

[^1]: Run `kubectl config get-contexts` to see a list of all contexts in your kubeconfig file; if `config_context` is not set in `providers.tf`, it will default to your current Kubernetes context, as long as one is set in your kubeconfig file
