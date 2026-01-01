resource "aws_s3_bucket" "s3_bucket_1" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "vpc-alb-3tier-project"
  }
}

resource "aws_s3_bucket_versioning" "s3_bucket_1" {
  bucket = aws_s3_bucket.s3_bucket_1.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_1" {
  bucket = aws_s3_bucket.s3_bucket_1.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
