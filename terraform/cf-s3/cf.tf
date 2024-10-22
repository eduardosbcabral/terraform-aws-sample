# Declare the aws_caller_identity data source
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  bucket   = "${each.value.name}-${local.global_config.env}"

  tags = local.default_tags
}

resource "aws_s3_bucket_cors_configuration" "this" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "DELETE", "GET"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_public_access_block" "this" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id
  acl      = "private"
}

resource "aws_s3_bucket_policy" "this" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id
  policy   = data.aws_iam_policy_document.this[each.key].json
}

data "aws_iam_policy_document" "this" {
  for_each = local.buckets

  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.this[each.key].arn,
      "${aws_s3_bucket.this[each.key].arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this[each.key].arn]
    }
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = local.buckets

  name                              = "s3-${aws_s3_bucket.this[each.key].id}-oac"
  description                       = "Grant cloudfront access to s3 bucket ${aws_s3_bucket.this[each.key].id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_website_configuration" "this" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.this[each.key].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_cloudfront_distribution" "this" {
  for_each = local.buckets

  origin {
    domain_name              = aws_s3_bucket.this[each.key].bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this[each.key].id
    origin_id                = "${aws_s3_bucket.this[each.key].id}-origin"
  }

  enabled             = true
  default_root_object = "index.html"

  # Handle custom error pages by returning index.html for 404 errors
  custom_error_response {
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 0
  }

  #   Optional - Extra CNAMEs (alternate domain names), if any, for this distribution
  aliases = each.value.domain_name != "" ? [each.value.domain_name] : []

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.this[each.key].id}-origin"

    forwarded_values {
      query_string = true

      headers = [
        "Origin",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
      ]

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = each.value.domain_name != "" ? "redirect-to-https" : "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = each.value.domain_name != "" ? data.aws_acm_certificate.my_acm[each.key].arn : null
    ssl_support_method  = each.value.domain_name != "" ? "sni-only" : null
    minimum_protocol_version = each.value.domain_name != "" ? "TLSv1.2_2021" : null
    cloudfront_default_certificate = each.value.domain_name != "" ? false : true
  }

  tags = local.default_tags
}