output "s3_bucket_name" {
  description = "Secure S3 bucket name"
  value       = aws_s3_bucket.secure_bucket.bucket
}

output "ec2_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}
