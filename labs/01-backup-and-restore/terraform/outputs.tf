output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app.dns_name
}

output "application_url" {
  description = "Application URL"
  value = var.create_route53_record
    ? "http://${var.record_name}.${var.domain_name}"
    : "http://${aws_lb.app.dns_name}"
}

output "backup_bucket_name" {
  description = "S3 backup bucket name"
  value       = aws_s3_bucket.backup.bucket
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.app.address
}

output "backup_vault_mumbai" {
  description = "AWS Backup vault in Mumbai"
  value       = aws_backup_vault.mumbai.name
}

output "backup_vault_hyderabad" {
  description = "AWS Backup vault in Hyderabad"
  value       = aws_backup_vault.hyderabad.name
}
