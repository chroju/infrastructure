resource "aws_iam_instance_profile" "bitwarden_role" {
  name = "bitwarden-instance-profile"
  role = aws_iam_role.bitwarden_role.name
}

resource "aws_iam_role" "bitwarden_role" {
  name               = "bitwarden-role"
  assume_role_policy = data.aws_iam_policy_document.bitwarden_role_assume_role_policy.json
}

data "aws_iam_policy_document" "bitwarden_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "bitwarden_role" {
  for_each = {
    ebs = aws_iam_policy.bitwarden_role.arn,
    ssm = data.aws_iam_policy.ssm_managed_policy.arn
  }

  role       = aws_iam_role.bitwarden_role.name
  policy_arn = each.value
}

resource "aws_iam_policy" "bitwarden_role" {
  name   = "bitwaden-role-policy"
  policy = data.aws_iam_policy_document.bitwarden_role.json
}

data "aws_iam_policy_document" "bitwarden_role" {
  statement {
    actions = [
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      aws_ebs_volume.bitwarden_data.arn,
    ]
  }

  statement {
    actions = [
      "ec2:DescribeVolumes",

    ]
    resources = [
      aws_ebs_volume.bitwarden_data.arn,
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
      aws_kms_key.bitwarden.arn,
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
}

data "aws_iam_policy" "ssm_managed_policy" {
  name = "AmazonSSMManagedInstanceCore"
}
