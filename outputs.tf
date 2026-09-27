output "s3_bucket_name" {
  description = "Nama S3 Bucket untuk target upload CI/CD"
  value       = aws_s3_bucket.portofolio_bucket.bucket
}

output "cloudfront_distribution_id" {
  description = "ID Distribusi CloudFront untuk Cache Invalidation"
  value       = aws_cloudfront_distribution.portofolio_cdn.id
}
