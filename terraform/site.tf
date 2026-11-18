# 静的WebサイトのHTMLファイルをS3へ配置
resource "aws_s3_object" "index" {
  bucket        = aws_s3_bucket.static_site.id
  key           = "index.html"
  source        = "${path.module}/site/index.html"
  etag          = filemd5("${path.module}/site/index.html")
  content_type  = "text/html; charset=utf-8"
  cache_control = "public, max-age=300"

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.static_site]
}
