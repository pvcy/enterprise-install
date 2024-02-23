variable "aws_lbc_sa" {
  description = "Name and namespace of the aws-load-balancer-controller ServiceAccount"
  type = object({
    name      = string
    namespace = string
  })
  default = {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
}

variable "aws_node_sa" {
  description = "Name and namespace of the aws-node ServiceAccount"
  type = object({
    name      = string
    namespace = string
  })
  default = {
    name      = "aws-node"
    namespace = "kube-system"
  }
}

variable "cert_manager_sa" {
  description = "Name and namespace of the cert-manager ServiceAccount"
  type = object({
    name      = string
    namespace = string
  })
  default = {
    name      = "cert-manager"
    namespace = "cert-manager"
  }
}

variable "dns_zone_name" {
  description = "Subdomain to be managed by the DNS Zone"
  type = string
}

variable "ebs_csi_controller_sa" {
  description = "Name and namespace of the ebs-csi-controller-sa ServiceAccount"
  type = object({
    name      = string
    namespace = string
  })
  default = {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
  }
}

variable "efs_csi_controller_sa" {
  description = "Name and namespace of the efs-csi-controller-sa ServiceAccount"
  type = object({
    name      = string
    namespace = string
  })
  default = {
    name      = "efs-csi-controller-sa"
    namespace = "kube-system"
  }
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type = string
}

variable "external_dns_sa" {
  description = "Name and namespace of the external-dns ServiceAccount"
  type = object({
    name      = string
    namespace = string
  })
  default = {
    name      = "external-dns"
    namespace = "external-dns"
  }
}

variable "oidc_provider_url" {
  description = "URL of the OpenID Connect (OIDC) Provider for the EKS cluster"
  type = string
}


variable "postgres_sa" {
  description = "Name and namespace of the postgres ServiceAccount"
  type = object({
    name      = string
    namespace = string
  })
  default = {
    name      = "postgres"
    namespace = "pvcy"
  }
}
variable "s3_bucket" {
  description = "AWS S3 bucket to hold backups of the application database"
  type = string
}
