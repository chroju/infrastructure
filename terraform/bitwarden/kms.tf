resource "aws_kms_key" "bitwarden" {}

resource "aws_kms_alias" "bitwarden" {
  name          = "alias/chroju/bitwarden"
  target_key_id = aws_kms_key.bitwarden.key_id
}
