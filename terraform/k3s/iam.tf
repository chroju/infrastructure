## k3s node

resource "aws_iam_instance_profile" "k3s_node_role" {
  name = "k3s-node-profile"
  role = aws_iam_role.k3s_node_role.name
}

resource "aws_iam_role" "k3s_node_role" {
  name               = "k3s-node-role"
  assume_role_policy = data.aws_iam_policy_document.k3s_node_role_assume_role_policy.json
}

data "aws_iam_policy_document" "k3s_node_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "k3s_node_role" {
  for_each = {
    ebs = aws_iam_policy.k3s_node_role.arn,
    ssm = data.aws_iam_policy.ssm_managed_policy.arn
  }

  role       = aws_iam_role.k3s_node_role.name
  policy_arn = each.value
}

resource "aws_iam_policy" "k3s_node_role" {
  name   = "k3s-node-role-policy"
  policy = data.aws_iam_policy_document.k3s_node_role.json
}

data "aws_iam_policy_document" "k3s_node_role" {
  statement {
    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      aws_ebs_volume.k3s_data.arn,
    ]
  }

  statement {
    actions = [
      "ec2:DescribeVolumes",

    ]
    resources = [
      aws_ebs_volume.k3s_data.arn,
    ]
  }

  statement {
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKeyWithoutPlainText",
      "kms:ReEncrypt",
    ]

    resources = [
      aws_kms_key.k3s.arn,
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
    }
  }

  statement {
    actions = [
      "ec2:createTags",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ssm:PutParameter",
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "aps:RemoteWrite",
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy" "ssm_managed_policy" {
  name = "AmazonSSMManagedInstanceCore"
}
