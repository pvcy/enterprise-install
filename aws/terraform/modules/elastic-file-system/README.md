# Elastic File System Module

This module creates a file system in [Amazon Elastic File System (EFS)](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html), as well as necessary network resources to allow access from your cluster. It also provisions an EFS-backed Kubernetes StorageClass. This is used by the Privacy Dynamics application to store temporary data that can be used simultaneously from multiple pods and nodes.

## Resources

The Terraform files provided here will create the following resources:

- A Security Group connected to your cluster's existing, primary VPC (any secondary VPCs are not considered)
- An Ingress Rule attached to the Security Group, allowing TCP traffic on port 2049
- An Egress Rule attached to the Security Group, allowing all outbound traffic
- An EFS file system
- A mount target for the file system in every subnet in your cluster's primary VPC
- A Kubernetes StorageClass linked to the file system

## Variables

The following variable must be set in order for this module to run correctly.

- `eks-cluster-name` = the name of your EKS cluster
