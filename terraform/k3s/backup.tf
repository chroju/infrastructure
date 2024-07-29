data "aws_kms_alias" "backup" {
  name = "alias/aws/backup"
}

data "aws_iam_role" "backup_default_role" {
  name = "AWSBackupDefaultServiceRole"
}

resource "aws_backup_vault" "default" {
  name        = "Default"
  kms_key_arn = data.aws_kms_alias.backup.target_key_arn
}

resource "aws_backup_plan" "daily_ec2_backup" {
  name = "DailyEC2Backup"

  rule {
    rule_name         = "DailyEC2Backup"
    target_vault_name = aws_backup_vault.default.name

    schedule = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = 14
    }
  }
}

resource "aws_backup_selection" "k3s" {
  name = "k3s"

  iam_role_arn = data.aws_iam_role.backup_default_role.arn
  plan_id      = aws_backup_plan.daily_ec2_backup.id

  resources = [
    aws_efs_file_system.k3s.arn,
  ]
}
