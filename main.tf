# --- KONFIGURASI PENGHUBUNG (PROVIDER) ---
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3         = "http://127.0.0.1:4566"
    cloudfront = "http://127.0.0.1:4566"
    sts        = "http://127.0.0.1:4566"
    iam        = "http://127.0.0.1:4566"
  }
}

# --- INFRASTRUKTUR S3 BUCKET ---
resource "aws_s3_bucket" "portofolio_bucket" {
  bucket = "portofolio-ku"
}

resource "aws_s3_bucket_website_configuration" "portofolio_website" {
  bucket = aws_s3_bucket.portofolio_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.portofolio_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.portofolio_bucket.arn}/*"
      }
    ]
  })
}

# --- INFRASTRUKTUR CLOUDFRONT CDN ---
resource "aws_cloudfront_distribution" "portofolio_cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.portofolio_bucket.bucket_regional_domain_name
    origin_id   = "S3-portofolio-ku"
  }

  default_cache_behavior {
    target_origin_id       = "S3-portofolio-ku"
    viewer_protocol_policy = "allow-all"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
