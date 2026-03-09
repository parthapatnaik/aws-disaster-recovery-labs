output "primary_instance_id" {
  description = "EC2 instance ID in Mumbai"
  value       = aws_instance.primary_ec2.id
}

output "primary_public_ip" {
  description = "Public IP of EC2 instance in Mumbai"
  value       = aws_instance.primary_ec2.public_ip
}
