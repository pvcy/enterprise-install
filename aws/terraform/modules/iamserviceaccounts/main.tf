data "aws_iam_openid_connect_provider" "this" {
  url = var.oidc_provider_url
}

resource "aws_route53_zone" "pvcy_zone" {
  name = var.dns_zone_name
}

resource "aws_s3_bucket" "backups" {
  bucket = var.s3_bucket
}

resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name = "AWSLoadBalancerControllerPolicy"
  policy = file("${path.module}/aws_lbc_policy.json")
}

resource "aws_iam_policy" "certmanager_policy" {
  name = "pvcy-cert-manager-route53-access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": "route53:GetChange",
        "Resource": "arn:aws:route53:::change/*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource": "arn:aws:route53:::hostedzone/${aws_route53_zone.pvcy_zone.zone_id}"
      },
      {
        "Effect": "Allow",
        "Action": "route53:ListHostedZonesByName",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_policy" "externaldns_policy" {
  name = "pvcy-external-dns-route53-access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource": [
          "arn:aws:route53:::hostedzone/${aws_route53_zone.pvcy_zone.zone_id}"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "route53:ListTagsForResource"
        ],
        "Resource": [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "backup_access_policy" {
  name = "pvcy-backup-s3-access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:ListBucket",
          "s3:PutObjectTagging",
          "s3:DeleteObject"
        ],
        "Resource": [
          "${aws_s3_bucket.backups.arn}/*",
          "${aws_s3_bucket.backups.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "aws_lbc_role" {
  name = "${var.eks_cluster_name}-aws-load-balancer-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.this.url}:aud" = "sts.amazonaws.com",
            "${data.aws_iam_openid_connect_provider.this.url}:sub" = "system:serviceaccount:${var.aws_lbc_sa.namespace}:${var.aws_lbc_sa.name}"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.this.arn}"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.aws_load_balancer_controller_policy.arn]
}

resource "aws_iam_role" "aws_node_role" {
  name = "${var.eks_cluster_name}-aws-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.this.url}:aud" = "sts.amazonaws.com",
            "${data.aws_iam_openid_connect_provider.this.url}:sub" = "system:serviceaccount:${var.aws_node_sa.namespace}:${var.aws_node_sa.name}"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.this.arn}"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
}

resource "aws_iam_role" "cert-manager-role" {
  name = "${var.eks_cluster_name}-cert-manager-serviceaccount-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.this.url}:aud" = "sts.amazonaws.com",
            "${data.aws_iam_openid_connect_provider.this.url}:sub" = "system:serviceaccount:${var.cert_manager_sa.namespace}:${var.cert_manager_sa.name}"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.this.arn}"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.certmanager_policy.arn]
}

resource "aws_iam_role" "ebs_csi_controller_role" {
  name = "${var.eks_cluster_name}-ebs-csi-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.this.url}:aud" = "sts.amazonaws.com",
            "${data.aws_iam_openid_connect_provider.this.url}:sub" = "system:serviceaccount:${var.ebs_csi_controller_sa.namespace}:${var.ebs_csi_controller_sa.name}"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.this.arn}"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}

resource "aws_iam_role" "efs_csi_controller_role" {
  name = "${var.eks_cluster_name}-efs-csi-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.this.url}:aud" = "sts.amazonaws.com",
            "${data.aws_iam_openid_connect_provider.this.url}:sub" = "system:serviceaccount:${var.efs_csi_controller_sa.namespace}:${var.efs_csi_controller_sa.name}"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.this.arn}"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"]
}

resource "aws_iam_role" "external-dns-role" {
  name = "${var.eks_cluster_name}-external-dns-serviceaccount-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.this.url}:aud" = "sts.amazonaws.com",
            "${data.aws_iam_openid_connect_provider.this.url}:sub" = "system:serviceaccount:${var.external_dns_sa.namespace}:${var.external_dns_sa.name}"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.this.arn}"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.externaldns_policy.arn]
}

resource "aws_iam_role" "postgres-role" {
  name = "${var.eks_cluster_name}-postgres-serviceaccount-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${data.aws_iam_openid_connect_provider.this.url}:aud" = "sts.amazonaws.com",
            "${data.aws_iam_openid_connect_provider.this.url}:sub" = "system:serviceaccount:${var.postgres_sa.namespace}:${var.postgres_sa.name}"
          }
        }
        Effect = "Allow"
        Principal = {
          Federated = "${data.aws_iam_openid_connect_provider.this.arn}"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.backup_access_policy.arn]
}

resource "kubernetes_namespace" "cert-manager_ns" {
  metadata {
    name = var.cert_manager_sa.namespace
  }
}

resource "kubernetes_namespace" "external-dns_ns" {
  metadata {
    name = var.external_dns_sa.namespace
  }
}

resource "kubernetes_namespace" "postgres_ns" {
  metadata {
    name = var.postgres_sa.namespace
  }
}

resource "kubernetes_service_account" "externaldns_serviceaccount" {
  depends_on = [ kubernetes_namespace.external-dns_ns ]
  metadata {
    name        = var.external_dns_sa.name
    namespace   = var.external_dns_sa.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external-dns-role.arn
    }
  }
}

resource "kubernetes_service_account" "certmanager_serviceaccount" {
  depends_on = [ kubernetes_namespace.cert-manager_ns ]
  metadata {
    name        = var.cert_manager_sa.name
    namespace   = var.cert_manager_sa.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cert-manager-role.arn
    }
  }
}

resource "kubernetes_service_account" "postgres_serviceaccount" {
  depends_on = [ kubernetes_namespace.postgres_ns ]
  metadata {
    name        = var.postgres_sa.name
    namespace   = var.postgres_sa.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.postgres-role.arn
    }
  }
}

resource "kubernetes_service_account" "aws_lbc_serviceaccount" {
  metadata {
    name        = var.aws_lbc_sa.name
    namespace   = var.aws_lbc_sa.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lbc_role.arn
    }
  }
}
