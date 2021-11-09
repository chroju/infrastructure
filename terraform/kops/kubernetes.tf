locals {
  cluster_name                 = "kops.chroju.dev"
  master_autoscaling_group_ids = [aws_autoscaling_group.master-ap-northeast-1a-masters-kops-chroju-dev.id]
  master_security_group_ids    = [aws_security_group.masters-kops-chroju-dev.id]
  masters_role_arn             = aws_iam_role.masters-kops-chroju-dev.arn
  masters_role_name            = aws_iam_role.masters-kops-chroju-dev.name
  node_autoscaling_group_ids   = [aws_autoscaling_group.nodes-ap-northeast-1a-kops-chroju-dev.id]
  node_security_group_ids      = [aws_security_group.nodes-kops-chroju-dev.id]
  node_subnet_ids              = [aws_subnet.ap-northeast-1a-kops-chroju-dev.id]
  nodes_role_arn               = aws_iam_role.nodes-kops-chroju-dev.arn
  nodes_role_name              = aws_iam_role.nodes-kops-chroju-dev.name
  region                       = "ap-northeast-1"
  route_table_public_id        = aws_route_table.kops-chroju-dev.id
  subnet_ap-northeast-1a_id    = aws_subnet.ap-northeast-1a-kops-chroju-dev.id
  vpc_cidr_block               = aws_vpc.kops-chroju-dev.cidr_block
  vpc_id                       = aws_vpc.kops-chroju-dev.id
}

output "cluster_name" {
  value = "kops.chroju.dev"
}

output "master_autoscaling_group_ids" {
  value = [aws_autoscaling_group.master-ap-northeast-1a-masters-kops-chroju-dev.id]
}

output "master_security_group_ids" {
  value = [aws_security_group.masters-kops-chroju-dev.id]
}

output "masters_role_arn" {
  value = aws_iam_role.masters-kops-chroju-dev.arn
}

output "masters_role_name" {
  value = aws_iam_role.masters-kops-chroju-dev.name
}

output "node_autoscaling_group_ids" {
  value = [aws_autoscaling_group.nodes-ap-northeast-1a-kops-chroju-dev.id]
}

output "node_security_group_ids" {
  value = [aws_security_group.nodes-kops-chroju-dev.id]
}

output "node_subnet_ids" {
  value = [aws_subnet.ap-northeast-1a-kops-chroju-dev.id]
}

output "nodes_role_arn" {
  value = aws_iam_role.nodes-kops-chroju-dev.arn
}

output "nodes_role_name" {
  value = aws_iam_role.nodes-kops-chroju-dev.name
}

output "region" {
  value = "ap-northeast-1"
}

output "route_table_public_id" {
  value = aws_route_table.kops-chroju-dev.id
}

output "subnet_ap-northeast-1a_id" {
  value = aws_subnet.ap-northeast-1a-kops-chroju-dev.id
}

output "vpc_cidr_block" {
  value = aws_vpc.kops-chroju-dev.cidr_block
}

output "vpc_id" {
  value = aws_vpc.kops-chroju-dev.id
}

resource "aws_autoscaling_group" "master-ap-northeast-1a-masters-kops-chroju-dev" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.master-ap-northeast-1a-masters-kops-chroju-dev.id
    version = aws_launch_template.master-ap-northeast-1a-masters-kops-chroju-dev.latest_version
  }
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 1
  name                  = "master-ap-northeast-1a.masters.kops.chroju.dev"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "kops.chroju.dev"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "master-ap-northeast-1a.masters.kops.chroju.dev"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "master-ap-northeast-1a"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/kops-controller-pki"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"
    propagate_at_launch = true
    value               = "master"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/master"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/exclude-from-external-load-balancers"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/master"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "master-ap-northeast-1a"
  }
  tag {
    key                 = "kubernetes.io/cluster/kops.chroju.dev"
    propagate_at_launch = true
    value               = "owned"
  }
  vpc_zone_identifier = [aws_subnet.ap-northeast-1a-kops-chroju-dev.id]
}

resource "aws_autoscaling_group" "nodes-ap-northeast-1a-kops-chroju-dev" {
  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  launch_template {
    id      = aws_launch_template.nodes-ap-northeast-1a-kops-chroju-dev.id
    version = aws_launch_template.nodes-ap-northeast-1a-kops-chroju-dev.latest_version
  }
  max_size              = 1
  metrics_granularity   = "1Minute"
  min_size              = 1
  name                  = "nodes-ap-northeast-1a.kops.chroju.dev"
  protect_from_scale_in = false
  tag {
    key                 = "KubernetesCluster"
    propagate_at_launch = true
    value               = "kops.chroju.dev"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "nodes-ap-northeast-1a.kops.chroju.dev"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes-ap-northeast-1a"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"
    propagate_at_launch = true
    value               = "node"
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node"
    propagate_at_launch = true
    value               = ""
  }
  tag {
    key                 = "k8s.io/role/node"
    propagate_at_launch = true
    value               = "1"
  }
  tag {
    key                 = "kops.k8s.io/instancegroup"
    propagate_at_launch = true
    value               = "nodes-ap-northeast-1a"
  }
  tag {
    key                 = "kubernetes.io/cluster/kops.chroju.dev"
    propagate_at_launch = true
    value               = "owned"
  }
  vpc_zone_identifier = [aws_subnet.ap-northeast-1a-kops-chroju-dev.id]
}

resource "aws_ebs_volume" "a-etcd-events-kops-chroju-dev" {
  availability_zone = "ap-northeast-1a"
  encrypted         = true
  iops              = 3000
  size              = 20
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "a.etcd-events.kops.chroju.dev"
    "k8s.io/etcd/events"                    = "a/a"
    "k8s.io/role/master"                    = "1"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
  throughput = 125
  type       = "gp3"
}

resource "aws_ebs_volume" "a-etcd-main-kops-chroju-dev" {
  availability_zone = "ap-northeast-1a"
  encrypted         = true
  iops              = 3000
  size              = 20
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "a.etcd-main.kops.chroju.dev"
    "k8s.io/etcd/main"                      = "a/a"
    "k8s.io/role/master"                    = "1"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
  throughput = 125
  type       = "gp3"
}

resource "aws_iam_instance_profile" "masters-kops-chroju-dev" {
  name = "masters.kops.chroju.dev"
  role = aws_iam_role.masters-kops-chroju-dev.name
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "masters.kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
}

resource "aws_iam_instance_profile" "nodes-kops-chroju-dev" {
  name = "nodes.kops.chroju.dev"
  role = aws_iam_role.nodes-kops-chroju-dev.name
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "nodes.kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
}

resource "aws_iam_role" "masters-kops-chroju-dev" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_masters.kops.chroju.dev_policy")
  name               = "masters.kops.chroju.dev"
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "masters.kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
}

resource "aws_iam_role" "nodes-kops-chroju-dev" {
  assume_role_policy = file("${path.module}/data/aws_iam_role_nodes.kops.chroju.dev_policy")
  name               = "nodes.kops.chroju.dev"
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "nodes.kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
}

resource "aws_iam_role_policy_attachment" "master-ssm-policy" {
  role       = aws_iam_role.masters-kops-chroju-dev.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "node-ssm-policy" {
  role       = aws_iam_role.nodes-kops-chroju-dev.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy" "masters-kops-chroju-dev" {
  name   = "masters.kops.chroju.dev"
  policy = file("${path.module}/data/aws_iam_role_policy_masters.kops.chroju.dev_policy")
  role   = aws_iam_role.masters-kops-chroju-dev.name
}

resource "aws_iam_role_policy" "nodes-kops-chroju-dev" {
  name   = "nodes.kops.chroju.dev"
  policy = file("${path.module}/data/aws_iam_role_policy_nodes.kops.chroju.dev_policy")
  role   = aws_iam_role.nodes-kops-chroju-dev.name
}

resource "aws_internet_gateway" "kops-chroju-dev" {
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
  vpc_id = aws_vpc.kops-chroju-dev.id
}

resource "aws_key_pair" "kubernetes-kops-chroju-dev-0dbf6772bb4d45ef8df5fd3f91a30f76" {
  key_name   = "kubernetes.kops.chroju.dev-0d:bf:67:72:bb:4d:45:ef:8d:f5:fd:3f:91:a3:0f:76"
  public_key = file("${path.module}/data/aws_key_pair_kubernetes.kops.chroju.dev-0dbf6772bb4d45ef8df5fd3f91a30f76_public_key")
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
}

resource "aws_launch_template" "master-ap-northeast-1a-masters-kops-chroju-dev" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 64
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.masters-kops-chroju-dev.id
  }
  image_id      = "ami-0adcb4f170c975f15"
  instance_type = "t3.small"
  key_name      = aws_key_pair.kubernetes-kops-chroju-dev-0dbf6772bb4d45ef8df5fd3f91a30f76.id
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 3
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "master-ap-northeast-1a.masters.kops.chroju.dev"
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.masters-kops-chroju-dev.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                                                     = "kops.chroju.dev"
      "Name"                                                                                                  = "master-ap-northeast-1a.masters.kops.chroju.dev"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"                               = "master-ap-northeast-1a"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/kops-controller-pki"                         = ""
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"                                      = "master"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"                   = ""
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/master"                          = ""
      "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/exclude-from-external-load-balancers" = ""
      "k8s.io/role/master"                                                                                    = "1"
      "kops.k8s.io/instancegroup"                                                                             = "master-ap-northeast-1a"
      "kubernetes.io/cluster/kops.chroju.dev"                                                                 = "owned"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                                                     = "kops.chroju.dev"
      "Name"                                                                                                  = "master-ap-northeast-1a.masters.kops.chroju.dev"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"                               = "master-ap-northeast-1a"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/kops-controller-pki"                         = ""
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"                                      = "master"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"                   = ""
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/master"                          = ""
      "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/exclude-from-external-load-balancers" = ""
      "k8s.io/role/master"                                                                                    = "1"
      "kops.k8s.io/instancegroup"                                                                             = "master-ap-northeast-1a"
      "kubernetes.io/cluster/kops.chroju.dev"                                                                 = "owned"
    }
  }
  tags = {
    "KubernetesCluster"                                                                                     = "kops.chroju.dev"
    "Name"                                                                                                  = "master-ap-northeast-1a.masters.kops.chroju.dev"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"                               = "master-ap-northeast-1a"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/kops-controller-pki"                         = ""
    "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"                                      = "master"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/control-plane"                   = ""
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/master"                          = ""
    "k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/exclude-from-external-load-balancers" = ""
    "k8s.io/role/master"                                                                                    = "1"
    "kops.k8s.io/instancegroup"                                                                             = "master-ap-northeast-1a"
    "kubernetes.io/cluster/kops.chroju.dev"                                                                 = "owned"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_master-ap-northeast-1a.masters.kops.chroju.dev_user_data")
}

resource "aws_launch_template" "nodes-ap-northeast-1a-kops-chroju-dev" {
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 128
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.nodes-kops-chroju-dev.id
  }
  image_id      = "ami-0adcb4f170c975f15"
  instance_type = "t3.small"
  key_name      = aws_key_pair.kubernetes-kops-chroju-dev-0dbf6772bb4d45ef8df5fd3f91a30f76.id
  lifecycle {
    create_before_destroy = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "disabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring {
    enabled = false
  }
  name = "nodes-ap-northeast-1a.kops.chroju.dev"
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    ipv6_address_count          = 0
    security_groups             = [aws_security_group.nodes-kops-chroju-dev.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      "KubernetesCluster"                                                          = "kops.chroju.dev"
      "Name"                                                                       = "nodes-ap-northeast-1a.kops.chroju.dev"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-ap-northeast-1a"
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "nodes-ap-northeast-1a"
      "kubernetes.io/cluster/kops.chroju.dev"                                      = "owned"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      "KubernetesCluster"                                                          = "kops.chroju.dev"
      "Name"                                                                       = "nodes-ap-northeast-1a.kops.chroju.dev"
      "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-ap-northeast-1a"
      "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
      "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
      "k8s.io/role/node"                                                           = "1"
      "kops.k8s.io/instancegroup"                                                  = "nodes-ap-northeast-1a"
      "kubernetes.io/cluster/kops.chroju.dev"                                      = "owned"
    }
  }
  tags = {
    "KubernetesCluster"                                                          = "kops.chroju.dev"
    "Name"                                                                       = "nodes-ap-northeast-1a.kops.chroju.dev"
    "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"    = "nodes-ap-northeast-1a"
    "k8s.io/cluster-autoscaler/node-template/label/kubernetes.io/role"           = "node"
    "k8s.io/cluster-autoscaler/node-template/label/node-role.kubernetes.io/node" = ""
    "k8s.io/role/node"                                                           = "1"
    "kops.k8s.io/instancegroup"                                                  = "nodes-ap-northeast-1a"
    "kubernetes.io/cluster/kops.chroju.dev"                                      = "owned"
  }
  user_data = filebase64("${path.module}/data/aws_launch_template_nodes-ap-northeast-1a.kops.chroju.dev_user_data")
}

resource "aws_route" "route-0-0-0-0--0" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kops-chroju-dev.id
  route_table_id         = aws_route_table.kops-chroju-dev.id
}

resource "aws_route" "route-__--0" {
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.kops-chroju-dev.id
  route_table_id              = aws_route_table.kops-chroju-dev.id
}

resource "aws_route_table" "kops-chroju-dev" {
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
    "kubernetes.io/kops/role"               = "public"
  }
  vpc_id = aws_vpc.kops-chroju-dev.id
}

resource "aws_route_table_association" "ap-northeast-1a-kops-chroju-dev" {
  route_table_id = aws_route_table.kops-chroju-dev.id
  subnet_id      = aws_subnet.ap-northeast-1a-kops-chroju-dev.id
}

resource "aws_s3_bucket_object" "cluster-completed-spec" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_cluster-completed.spec_content")
  key                    = "kops.chroju.dev/cluster-completed.spec"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "etcd-cluster-spec-events" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_etcd-cluster-spec-events_content")
  key                    = "kops.chroju.dev/backups/etcd/events/control/etcd-cluster-spec"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "etcd-cluster-spec-main" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_etcd-cluster-spec-main_content")
  key                    = "kops.chroju.dev/backups/etcd/main/control/etcd-cluster-spec"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-aws-ebs-csi-driver-addons-k8s-io-k8s-1-17" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-aws-ebs-csi-driver.addons.k8s.io-k8s-1.17_content")
  key                    = "kops.chroju.dev/addons/aws-ebs-csi-driver.addons.k8s.io/k8s-1.17.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-bootstrap" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-bootstrap_content")
  key                    = "kops.chroju.dev/addons/bootstrap-channel.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-core-addons-k8s-io" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-core.addons.k8s.io_content")
  key                    = "kops.chroju.dev/addons/core.addons.k8s.io/v1.4.0.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-coredns-addons-k8s-io-k8s-1-12" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-coredns.addons.k8s.io-k8s-1.12_content")
  key                    = "kops.chroju.dev/addons/coredns.addons.k8s.io/k8s-1.12.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-dns-controller-addons-k8s-io-k8s-1-12" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-dns-controller.addons.k8s.io-k8s-1.12_content")
  key                    = "kops.chroju.dev/addons/dns-controller.addons.k8s.io/k8s-1.12.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-kops-controller-addons-k8s-io-k8s-1-16" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-kops-controller.addons.k8s.io-k8s-1.16_content")
  key                    = "kops.chroju.dev/addons/kops-controller.addons.k8s.io/k8s-1.16.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-kubelet-api-rbac-addons-k8s-io-k8s-1-9" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-kubelet-api.rbac.addons.k8s.io-k8s-1.9_content")
  key                    = "kops.chroju.dev/addons/kubelet-api.rbac.addons.k8s.io/k8s-1.9.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-limit-range-addons-k8s-io" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-limit-range.addons.k8s.io_content")
  key                    = "kops.chroju.dev/addons/limit-range.addons.k8s.io/v1.5.0.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-networking-projectcalico-org-k8s-1-16" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-networking.projectcalico.org-k8s-1.16_content")
  key                    = "kops.chroju.dev/addons/networking.projectcalico.org/k8s-1.16.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-chroju-dev-addons-storage-aws-addons-k8s-io-v1-15-0" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops.chroju.dev-addons-storage-aws.addons.k8s.io-v1.15.0_content")
  key                    = "kops.chroju.dev/addons/storage-aws.addons.k8s.io/v1.15.0.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "kops-version-txt" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_kops-version.txt_content")
  key                    = "kops.chroju.dev/kops-version.txt"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "manifests-etcdmanager-events" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_manifests-etcdmanager-events_content")
  key                    = "kops.chroju.dev/manifests/etcd/events.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "manifests-etcdmanager-main" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_manifests-etcdmanager-main_content")
  key                    = "kops.chroju.dev/manifests/etcd/main.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "manifests-static-kube-apiserver-healthcheck" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_manifests-static-kube-apiserver-healthcheck_content")
  key                    = "kops.chroju.dev/manifests/static/kube-apiserver-healthcheck.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "nodeupconfig-master-ap-northeast-1a" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_nodeupconfig-master-ap-northeast-1a_content")
  key                    = "kops.chroju.dev/igconfig/master/master-ap-northeast-1a/nodeupconfig.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "nodeupconfig-nodes-ap-northeast-1a" {
  bucket                 = "chroju-kops-config"
  content                = file("${path.module}/data/aws_s3_bucket_object_nodeupconfig-nodes-ap-northeast-1a_content")
  key                    = "kops.chroju.dev/igconfig/node/nodes-ap-northeast-1a/nodeupconfig.yaml"
  provider               = aws.files
  server_side_encryption = "AES256"
}

resource "aws_security_group" "masters-kops-chroju-dev" {
  description = "Security group for masters"
  name        = "masters.kops.chroju.dev"
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "masters.kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
  vpc_id = aws_vpc.kops-chroju-dev.id
}

resource "aws_security_group" "nodes-kops-chroju-dev" {
  description = "Security group for nodes"
  name        = "nodes.kops.chroju.dev"
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "nodes.kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
  vpc_id = aws_vpc.kops-chroju-dev.id
}

# resource "aws_security_group_rule" "from-0-0-0-0--0-ingress-tcp-22to22-masters-kops-chroju-dev" {
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.masters-kops-chroju-dev.id
#   to_port           = 22
#   type              = "ingress"
# }

# resource "aws_security_group_rule" "from-0-0-0-0--0-ingress-tcp-22to22-nodes-kops-chroju-dev" {
#   cidr_blocks       = ["0.0.0.0/0"]
#   from_port         = 22
#   protocol          = "tcp"
#   security_group_id = aws_security_group.nodes-kops-chroju-dev.id
#   to_port           = 22
#   type              = "ingress"
# }

resource "aws_security_group_rule" "from-0-0-0-0--0-ingress-tcp-443to443-masters-kops-chroju-dev" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.masters-kops-chroju-dev.id
  to_port           = 443
  type              = "ingress"
}

# resource "aws_security_group_rule" "from-__--0-ingress-tcp-22to22-masters-kops-chroju-dev" {
#   from_port         = 22
#   ipv6_cidr_blocks  = ["::/0"]
#   protocol          = "tcp"
#   security_group_id = aws_security_group.masters-kops-chroju-dev.id
#   to_port           = 22
#   type              = "ingress"
# }

# resource "aws_security_group_rule" "from-__--0-ingress-tcp-22to22-nodes-kops-chroju-dev" {
#   from_port         = 22
#   ipv6_cidr_blocks  = ["::/0"]
#   protocol          = "tcp"
#   security_group_id = aws_security_group.nodes-kops-chroju-dev.id
#   to_port           = 22
#   type              = "ingress"
# }

resource "aws_security_group_rule" "from-__--0-ingress-tcp-443to443-masters-kops-chroju-dev" {
  from_port         = 443
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "tcp"
  security_group_id = aws_security_group.masters-kops-chroju-dev.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "from-masters-kops-chroju-dev-egress-all-0to0-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.masters-kops-chroju-dev.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-masters-kops-chroju-dev-egress-all-0to0-__--0" {
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  security_group_id = aws_security_group.masters-kops-chroju-dev.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-masters-kops-chroju-dev-ingress-all-0to0-masters-kops-chroju-dev" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.masters-kops-chroju-dev.id
  source_security_group_id = aws_security_group.masters-kops-chroju-dev.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-masters-kops-chroju-dev-ingress-all-0to0-nodes-kops-chroju-dev" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-kops-chroju-dev.id
  source_security_group_id = aws_security_group.masters-kops-chroju-dev.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-kops-chroju-dev-egress-all-0to0-0-0-0-0--0" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.nodes-kops-chroju-dev.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-nodes-kops-chroju-dev-egress-all-0to0-__--0" {
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  security_group_id = aws_security_group.nodes-kops-chroju-dev.id
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "from-nodes-kops-chroju-dev-ingress-4-0to0-masters-kops-chroju-dev" {
  from_port                = 0
  protocol                 = "4"
  security_group_id        = aws_security_group.masters-kops-chroju-dev.id
  source_security_group_id = aws_security_group.nodes-kops-chroju-dev.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-kops-chroju-dev-ingress-all-0to0-nodes-kops-chroju-dev" {
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes-kops-chroju-dev.id
  source_security_group_id = aws_security_group.nodes-kops-chroju-dev.id
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-kops-chroju-dev-ingress-tcp-1to2379-masters-kops-chroju-dev" {
  from_port                = 1
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-kops-chroju-dev.id
  source_security_group_id = aws_security_group.nodes-kops-chroju-dev.id
  to_port                  = 2379
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-kops-chroju-dev-ingress-tcp-2382to4000-masters-kops-chroju-dev" {
  from_port                = 2382
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-kops-chroju-dev.id
  source_security_group_id = aws_security_group.nodes-kops-chroju-dev.id
  to_port                  = 4000
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-kops-chroju-dev-ingress-tcp-4003to65535-masters-kops-chroju-dev" {
  from_port                = 4003
  protocol                 = "tcp"
  security_group_id        = aws_security_group.masters-kops-chroju-dev.id
  source_security_group_id = aws_security_group.nodes-kops-chroju-dev.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "from-nodes-kops-chroju-dev-ingress-udp-1to65535-masters-kops-chroju-dev" {
  from_port                = 1
  protocol                 = "udp"
  security_group_id        = aws_security_group.masters-kops-chroju-dev.id
  source_security_group_id = aws_security_group.nodes-kops-chroju-dev.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_subnet" "ap-northeast-1a-kops-chroju-dev" {
  availability_zone = "ap-northeast-1a"
  cidr_block        = "172.20.32.0/19"
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "ap-northeast-1a.kops.chroju.dev"
    "SubnetType"                            = "Public"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
    "kubernetes.io/role/elb"                = "1"
    "kubernetes.io/role/internal-elb"       = "1"
  }
  vpc_id = aws_vpc.kops-chroju-dev.id
}

resource "aws_vpc" "kops-chroju-dev" {
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = "172.20.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "kops-chroju-dev" {
  domain_name         = "ap-northeast-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    "KubernetesCluster"                     = "kops.chroju.dev"
    "Name"                                  = "kops.chroju.dev"
    "kubernetes.io/cluster/kops.chroju.dev" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "kops-chroju-dev" {
  dhcp_options_id = aws_vpc_dhcp_options.kops-chroju-dev.id
  vpc_id          = aws_vpc.kops-chroju-dev.id
}
