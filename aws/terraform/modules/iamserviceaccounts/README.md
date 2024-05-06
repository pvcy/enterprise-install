# IAMServiceAccounts Module

This module creates IAM Roles and Policies, as well as Kubernetes `ServiceAccount` resources, to allow certain workloads access to AWS resources, such as Route 53 and S3. Some of these are intended to provide access for EKS Add-ons, while others are intended for Helm deployments that will be installed with Replicated.

## Resources

The Terraform files provided here will create the following resources:

- A Route 53 DNS Zone for Privacy Dynamics software
- An S3 bucket for backups of the Privacy Dynamics application database
- Seven IAM Roles for Service Accounts (IRSA), with their attached IAM Policies
- Seven Kubernetes ServiceAccounts, each linked to one of the IAM Roles

An IRSA role has a Trust Relationship allowing outside API requests to assume the role, as long as the requests come from a specific Kubernetes ServiceAccount through an OpenID Connect (OIDC) Provider. This Role can then manipulate AWS resources allowed in the attached IAM Policy. See [our documentation](https://www.privacydynamics.io/docs/enterprise/aws_iamserviceaccounts) for a complete listing of these Roles.

> NOTE: The `eksctl` utility, which can be used to manually create these ServiceAccounts and Roles (referred to collectively as IAMServiceAccounts), uses CloudFormation to create the necessary resources. If requested to display a list of existing IAMServiceAccounts on a cluster, it queries CloudFormation for the information. As Terraform does not employ CloudFormation, `eksctl get iamserviceaccounts` will not show resources created with Terraform. However, the resources will function as intended and are equivalent in every other way.

## Variables

The following variables must be set in order for this module to run correctly. Several variables have default values that should work in most cases, but can be overriden by defining a value when invoking this module from the parent `main.tf` file. Variables without a default value must have a value supplied from the parent `main.tf` in order for this module to run successfully.

| Variable                    | Description                                                   | Default                      |
|-----------------------------|---------------------------------------------------------------|------------------------------|
| `aws_node_sa.name`          | name of the aws-node ServiceAccount                           | aws-node                     |
| `aws_node_sa.namespace`     | namespace of the aws-node ServiceAccount                      | kube-system                  |
| `aws_lbc_sa.name`           | name of the aws-load-balancer-controller ServiceAccount       | aws-load-balancer-controller |
| `aws_lbc_sa.namespace`      | namespace of the aws-load-balancer-controller ServiceAccount  | kube-system                  |
| `ebs_csi_controller_sa.name`| name of the ebs-csi-controller-sa ServiceAccount              | ebs-csi-controller-sa        |
| `ebs_csi_controller_sa.namespace` | namespace of the ebs-csi-controller-sa ServiceAccount   | kube-system                  |
| `efs_csi_controller_sa.name`| name of the efs-csi-controller-sa ServiceAccount              | efs-csi-controller-sa        |
| `efs_csi_controller_sa.namespace` | namespace of the efs-csi-controller-sa ServiceAccount   | kube-system                  |
| `cert_manager_sa.name`      | name of the cert-manager ServiceAccount                       | cert-manager                 |
| `cert_manager_sa.namespace` | namespace of the cert-manager ServiceAccount                  | cert-manager                 |
| `dns_zone_name`             | the subdomain for the DNS zone to be created                  |                              |
| `eks_cluster_name`          | the name of the EKS cluster                                   |                              |
| `external_dns_sa.name`      | name of the external-dns ServiceAccount                       | external-dns                 |
| `external_dns_sa.namespace` | namespace of the external-dns ServiceAccount                  | external-dns                 |
| `postgres_sa.name`          | name of the postgres ServiceAccount                           | postgres                     |
| `postgres_sa.namespace`     | namespace of the postgres ServiceAccount                      | pvcy                         |
| `s3_bucket`                 | the name for S3 Bucket to be created                          |                              |
