variable "primary_region" {
  description = "Primary AWS Region"
  default     = "ap-south-1"
}

variable "dr_region" {
  description = "Disaster Recovery AWS Region"
  default     = "ap-south-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI for EC2 instance"
  type        = string
}
