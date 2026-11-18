output "cloudfront_url" {
  description = "CloudFrontの公開URL"
  value       = "https://${aws_cloudfront_distribution.static_site.domain_name}"
}

output "s3_bucket_name" {
  description = "静的Webサイト用S3バケット名"
  value       = aws_s3_bucket.static_site.id
}

output "cloudfront_distribution_id" {
  description = "キャッシュ無効化に使用するディストリビューションID"
  value       = aws_cloudfront_distribution.static_site.id
}

output "s3_direct_url" {
  description = "匿名アクセスが403になることを確認するURL"
  value       = "https://${aws_s3_bucket.static_site.bucket_regional_domain_name}/index.html"
}
