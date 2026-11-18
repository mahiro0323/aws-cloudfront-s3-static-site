# 静的Webサイト用のS3バケット
resource "aws_s3_bucket" "static_site" {
  bucket_prefix = "${var.project_name}-"

  tags = {
    Project   = "aws-cloudfront-s3-static-site"
    ManagedBy = "Terraform"
    Purpose   = "Learning"
  }
}

# S3のパブリックアクセスをすべてブロック
resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# バケット内のオブジェクトを暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
