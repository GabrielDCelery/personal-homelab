resource "aws_s3_bucket" "blog" {
  bucket        = var.domain_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "blog" {
  bucket     = aws_s3_bucket.blog.id
  depends_on = [aws_s3_bucket.blog]

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.blog.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "blog" {
  bucket = aws_s3_bucket.blog.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyAllExceptCloudflareOrTerraform"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.blog.arn,
          "${aws_s3_bucket.blog.arn}/*"
        ]
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = var.cloudflare_ipv4_address_ranges
          }
          StringNotLike = {
            "aws:PrincipalArn" : [
              "arn:aws:iam::${var.aws_account_id}:root",
              "arn:aws:iam::${var.aws_account_id}:user/*",
              "arn:aws:iam::${var.aws_account_id}:role/*"
            ]
          }
        }
      },
      {
        Sid       = "AllowCloudflareIPs"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.blog.arn}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.cloudflare_ipv4_address_ranges
          }
        }
      }
    ]
  })
}


locals {
  content_types = {
    "html" = "text/html",
    "htm"  = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
    "json" = "application/json",
    "jpg"  = "image/jpeg",
    "jpeg" = "image/jpeg",
    "png"  = "image/png",
    "gif"  = "image/gif",
    "svg"  = "image/svg+xml",
    "ico"  = "image/x-icon",
    "txt"  = "text/plain",
  }

  # use the fileset function to find all matching file types and then add them to a map, 
  # finally use the merge function to create a single map
  content_types_flattened = merge([
    for ext, content_type in local.content_types : {
      for file in fileset("${path.module}/../app/public", "**/*.${ext}") :
      file => content_type
    }
  ]...)
}

resource "aws_s3_object" "blog_files" {
  for_each = local.content_types_flattened

  bucket       = aws_s3_bucket.blog.id
  key          = each.key
  source       = "${path.module}/../app/public/${each.key}"
  content_type = each.value
  etag         = filemd5("${path.module}/../app/public/${each.key}")
}


resource "cloudflare_dns_record" "blog" {
  depends_on = [aws_s3_bucket_website_configuration.blog]
  zone_id    = var.cloudflare_zone_id
  name       = var.cloudflare_domain_cname_name
  type       = "CNAME"
  content    = aws_s3_bucket_website_configuration.blog.website_endpoint
  proxied    = true
  ttl        = 1
}

