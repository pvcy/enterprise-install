data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "tls_certificate" "oidc" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_route53_zone" "pvcy_zone" {
  name = var.dns_zone_name
}

resource "aws_s3_bucket" "backups" {
  bucket = var.s3_bucket
}

resource "aws_iam_policy" "backup_access" {
  name = "${var.eks_cluster_name}-backup-s3-access"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:ListBucket",
          "s3:PutObjectTagging",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.backups.arn}/*",
          "${aws_s3_bucket.backups.arn}"
        ]
      }
    ]
  })
}

resource "kubernetes_namespace" "certmanager" {
  metadata {
    name = var.cert_manager_sa.namespace
  }
}

resource "kubernetes_namespace" "externaldns" {
  metadata {
    name = var.external_dns_sa.namespace
  }
}

resource "kubernetes_namespace" "postgres_cluster" {
  metadata {
    name = var.postgres_sa.namespace
  }
}

module "ebs_csi_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.37"
  role_name = "${var.eks_cluster_name}-ebs-csi-role"

  role_policy_arns = {
    ebs_csi_policy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${var.ebs_csi_controller_sa.namespace}:${var.ebs_csi_controller_sa.name}"]
    }
  }
}

module "efs_csi_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.37"
  role_name = "${var.eks_cluster_name}-efs-csi-role"

  role_policy_arns = {
    efs_csi_policy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  }

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${var.efs_csi_controller_sa.namespace}:${var.efs_csi_controller_sa.name}"]
    }
  }
}

module "vpc_cni_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.37"
  role_name = "${var.eks_cluster_name}-vpc-cni-role"

  role_policy_arns = {
    eks_cni_policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${var.aws_node_sa.namespace}:${var.aws_node_sa.name}"]
    }
  }
}

module "aws_lbc_irsa_role" {
  source                                 = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                                = "~> 5.37"
  role_name                              = "${var.eks_cluster_name}-aws-lbc-role"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${var.aws_lbc_sa.namespace}:${var.aws_lbc_sa.name}"]
    }
  }
}

module "cert_manager_irsa_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                       = "~> 5.37"
  role_name                     = "${var.eks_cluster_name}-cert-manager-role"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = ["${aws_route53_zone.pvcy_zone.arn}"]

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${var.cert_manager_sa.namespace}:${var.cert_manager_sa.name}"]
    }
  }
}

module "external_dns_irsa_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version                       = "~> 5.37"
  role_name                     = "${var.eks_cluster_name}-external-dns-role"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["${aws_route53_zone.pvcy_zone.arn}"]

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${var.external_dns_sa.namespace}:${var.external_dns_sa.name}"]
    }
  }
}

module "postgres_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.37"
  role_name = "${var.eks_cluster_name}-postgres-role"

  role_policy_arns = {
    backup_policy = "${aws_iam_policy.backup_access.arn}"
  }

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["${var.postgres_sa.namespace}:${var.postgres_sa.name}"]
    }
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.eks_cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
}

resource "aws_eks_addon" "efs_csi" {
  cluster_name             = var.eks_cluster_name
  addon_name               = "aws-efs-csi-driver"
  service_account_role_arn = module.efs_csi_irsa_role.iam_role_arn
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name             = var.eks_cluster_name
  addon_name               = "vpc-cni"
  service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
}

resource "aws_eks_addon" "kubeproxy" {
  cluster_name = var.eks_cluster_name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = var.eks_cluster_name
  addon_name   = "coredns"
}

resource "kubernetes_service_account" "externaldns" {
  depends_on = [kubernetes_namespace.externaldns]

  metadata {
    name      = var.external_dns_sa.name
    namespace = var.external_dns_sa.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.external_dns_irsa_role.iam_role_arn
    }
  }
}

resource "kubernetes_service_account" "certmanager" {
  depends_on = [kubernetes_namespace.certmanager]

  metadata {
    name      = var.cert_manager_sa.name
    namespace = var.cert_manager_sa.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.cert_manager_irsa_role.iam_role_arn
    }
  }
}

resource "kubernetes_service_account" "postgres" {
  depends_on = [kubernetes_namespace.postgres_cluster]

  metadata {
    name      = var.postgres_sa.name
    namespace = var.postgres_sa.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.postgres_irsa_role.iam_role_arn
    }
  }
}

resource "kubernetes_service_account" "aws_lbc" {
  metadata {
    name      = var.aws_lbc_sa.name
    namespace = var.aws_lbc_sa.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_lbc_irsa_role.iam_role_arn
    }
  }
}
