resource "aws_kms_key" "k3s" {}

resource "aws_kms_alias" "k3s" {
  name          = "alias/chroju/k3s"
  target_key_id = aws_kms_key.k3s.key_id
}
