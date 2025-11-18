# random id for unique S3 bucket name
resource "random_id" "bucket_id" {
  byte_length = 4
}

# Secure S3 bucket
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "${var.project}-bucket-${random_id.bucket_id.hex}"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256" # AES256 or use KMS: AWS: use SSE-KMS for advanced control
      }
    }
  }

  tags = { Name = "${var.project}-bucket" }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# EC2 instance in private subnet (no public IP)
resource "aws_instance" "app" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.app_profile.name

  tags = { Name = "${var.project}-app" }
}
