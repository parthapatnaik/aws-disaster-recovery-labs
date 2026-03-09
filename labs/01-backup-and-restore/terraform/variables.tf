variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "creativeskillset"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "domain_name" {
  description = "Hosted zone name in Route 53"
  type        = string
  default     = "creativeskillset.click"
}

variable "record_name" {
  description = "DNS record name"
  type        = string
  default     = "www"
}

variable "create_route53_record" {
  description = "Whether to create Route 53 record"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.40.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.40.1.0/24", "10.40.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "Private app subnet CIDRs"
  type        = list(string)
  default     = ["10.40.11.0/24", "10.40.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "Private DB subnet CIDRs"
  type        = list(string)
  default     = ["10.40.21.0/24", "10.40.22.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for app tier"
  type        = string
  default     = "t3.micro"
}

variable "asg_min_size" {
  description = "ASG minimum size"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "ASG maximum size"
  type        = number
  default     = 2
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database admin username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage"
  type        = number
  default     = 20
}

variable "enable_multi_az_db" {
  description = "Enable Multi-AZ for primary RDS"
  type        = bool
  default     = false
}

variable "backup_schedule" {
  description = "AWS Backup schedule expression"
  type        = string
  default     = "cron(0 * * * ? *)"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
