resource "aws_s3_bucket" "kops_config" {
  bucket = "chroju-kops-config"
  versioning {
    enabled = true
  }
}
