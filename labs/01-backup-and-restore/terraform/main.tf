locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

data "aws_caller_identity" "current" {
  provider = aws.mumbai
}

data "aws_availability_zones" "available" {
  provider = aws.mumbai
  state    = "available"
}

data "aws_ami" "al2023" {
  provider    = aws.mumbai
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

########################################
# Networking
########################################

resource "aws_vpc" "main" {
  provider             = aws.mumbai
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  provider                = aws.mumbai
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-${count.index + 1}"
    Tier = "public"
  })
}

resource "aws_subnet" "private_app" {
  provider          = aws.mumbai
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-app-${count.index + 1}"
    Tier = "app"
  })
}

resource "aws_subnet" "private_db" {
  provider          = aws.mumbai
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-db-${count.index + 1}"
    Tier = "db"
  })
}

resource "aws_route_table" "public" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  provider               = aws.mumbai
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  provider       = aws.mumbai
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  provider = aws.mumbai
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat-eip"
  })
}

resource "aws_nat_gateway" "nat" {
  provider      = aws.mumbai
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-nat"
  })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  provider = aws.mumbai
  vpc_id   = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-rt"
  })
}

resource "aws_route" "private_nat" {
  provider               = aws.mumbai
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_app_assoc" {
  provider       = aws.mumbai
  count          = 2
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_assoc" {
  provider       = aws.mumbai
  count          = 2
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private.id
}

########################################
# Security Groups
########################################

resource "aws_security_group" "alb" {
  provider    = aws.mumbai
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}

resource "aws_security_group" "app" {
  provider    = aws.mumbai
  name        = "${local.name_prefix}-app-sg"
  description = "App tier security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
  })
}

resource "aws_security_group" "db" {
  provider    = aws.mumbai
  name        = "${local.name_prefix}-db-sg"
  description = "Database security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-sg"
  })
}

########################################
# IAM for EC2 / SSM
########################################

resource "aws_iam_role" "ec2_ssm_role" {
  provider = aws.mumbai
  name     = "${local.name_prefix}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  provider   = aws.mumbai
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  provider = aws.mumbai
  name     = "${local.name_prefix}-ec2-profile"
  role     = aws_iam_role.ec2_ssm_role.name
}

########################################
# S3 Backup Bucket
########################################

resource "aws_s3_bucket" "backup" {
  provider      = aws.mumbai
  bucket        = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-backup"
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backup-bucket"
  })
}

resource "aws_s3_bucket_versioning" "backup" {
  provider = aws.mumbai
  bucket   = aws_s3_bucket.backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  provider = aws.mumbai
  bucket   = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  provider                = aws.mumbai
  bucket                  = aws_s3_bucket.backup.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################################
# RDS
########################################

resource "aws_db_subnet_group" "main" {
  provider   = aws.mumbai
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

resource "aws_db_instance" "app" {
  provider               = aws.mumbai
  identifier             = "${local.name_prefix}-db"
  engine                 = "mysql"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = var.enable_multi_az_db
  storage_encrypted      = true
  backup_retention_period = 1
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = merge(local.common_tags, {
    Name   = "${local.name_prefix}-db"
    Backup = "daily"
  })
}

########################################
# ALB + App Tier
########################################

resource "aws_lb" "app" {
  provider           = aws.mumbai
  name               = substr("${replace(local.name_prefix, "_", "-")}-alb", 0, 32)
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "app" {
  provider    = aws.mumbai
  name        = substr("${replace(local.name_prefix, "_", "-")}-tg", 0, 32)
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tg"
  })
}

resource "aws_lb_listener" "http" {
  provider          = aws.mumbai
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_launch_template" "app" {
  provider      = aws.mumbai
  name          = "${local.name_prefix}-lt"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh.tftpl", {
    app_name    = var.project_name
    environment = var.environment
    db_endpoint = aws_db_instance.app.address
    region      = "ap-south-1"
  }))

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name   = "${local.name_prefix}-app"
      Backup = "daily"
      Tier   = "app"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags, {
      Name   = "${local.name_prefix}-app-volume"
      Backup = "daily"
      Tier   = "app"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-lt"
  })
}

resource "aws_autoscaling_group" "app" {
  provider            = aws.mumbai
  name                = "${local.name_prefix}-asg"
  min_size            = var.asg_min_size
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  vpc_zone_identifier = aws_subnet.private_app[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Backup"
    value               = "daily"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "Terraform"
    propagate_at_launch = true
  }
}

########################################
# AWS Backup
########################################

resource "aws_backup_vault" "mumbai" {
  provider = aws.mumbai
  name     = "${local.name_prefix}-vault-mumbai"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vault-mumbai"
  })
}

resource "aws_backup_vault" "hyderabad" {
  provider = aws.hyderabad
  name     = "${local.name_prefix}-vault-hyderabad"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vault-hyderabad"
  })
}

resource "aws_iam_role" "backup_role" {
  provider = aws.mumbai
  name     = "${local.name_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "backup_policy_backup" {
  provider   = aws.mumbai
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_policy_restore" {
  provider   = aws.mumbai
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "main" {
  provider = aws.mumbai
  name     = "${local.name_prefix}-backup-plan"

  rule {
    rule_name         = "hourly-backup"
    target_vault_name = aws_backup_vault.mumbai.name
    schedule          = var.backup_schedule
    start_window      = 60
    completion_window = 180

    lifecycle {
      delete_after = 1
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.hyderabad.arn

      lifecycle {
        delete_after = 1
      }
    }
  }

  tags = local.common_tags
}

resource "aws_backup_selection" "main" {
  provider     = aws.mumbai
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "${local.name_prefix}-backup-selection"
  plan_id      = aws_backup_plan.main.id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "daily"
  }

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Project"
    value = var.project_name
  }
}

########################################
# Route 53
########################################

data "aws_route53_zone" "main" {
  count        = var.create_route53_record ? 1 : 0
  provider     = aws.mumbai
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "www" {
  count    = var.create_route53_record ? 1 : 0
  provider = aws.mumbai
  zone_id  = data.aws_route53_zone.main[0].zone_id
  name     = "${var.record_name}.${var.domain_name}"
  type     = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
