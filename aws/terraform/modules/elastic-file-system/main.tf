data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

data "aws_vpc" "this" {
  id = data.aws_eks_cluster.this.vpc_config[0].vpc_id
}

data "aws_eks_node_groups" "this" {
  cluster_name = data.aws_eks_cluster.this.name
}

data "aws_eks_node_group" "this" {
  for_each        = toset(data.aws_eks_node_groups.this.names)

  cluster_name    = data.aws_eks_cluster.this.name
  node_group_name = each.key
}

locals {
  node_subnet_ids = distinct(flatten([
    for group in data.aws_eks_node_group.this : group.subnet_ids
  ]))
}

resource "aws_security_group" "efs-access" {
  description = "EFS Access for EKS"
  name        = "EFS-EKS-Access"
  vpc_id      = data.aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "nfs_traffic" {
  cidr_ipv4         = data.aws_vpc.this.cidr_block
  from_port         = 2049
  to_port           = 2049
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.efs-access.id
}

resource "aws_vpc_security_group_egress_rule" "all_outbound" {
  security_group_id = aws_security_group.efs-access.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_efs_file_system" "this" {
}

resource "aws_efs_mount_target" "name" {
  for_each = toset(local.node_subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs-access.id]
}

resource "kubernetes_storage_class" "efs-sc" {
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.this.id
    directoryPerms   = "700"
    gidRangeStart    = "1000"
    gidRangeEnd      = "2000"
    basePath         = "/dynamic_provisioning"
  }

  metadata {
    name = "efs-sc"
  }
}
