output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_profile.name
  description = "Name of the IAM instance profile attached to ASG instances for secure S3 access."
}

output "bucket_name" {
  value       = aws_s3_bucket.my_bucket.bucket
  description = "Name of the S3 bucket used for application storage and FinOps simulation data."
}

output "bucket_arn" {
  value       = aws_s3_bucket.my_bucket.arn
  description = "ARN of the S3 bucket used for secure resource access and policy attachment."
}