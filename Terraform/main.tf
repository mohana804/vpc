provider "aws" {
  region = "us-east-1" # Change as needed
}

# Create VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0" # Updated to the latest version

  name = "Three-Tier-VPC"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a"]
  public_subnets  = ["10.0.1.0/24"]
  private_subnets = ["10.0.3.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "dem"
  }
}

# Security Groups
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0" # Updated to the latest version

  name        = "three-tier-sg"
  description = "Security group for three-tier architecture"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

# Application Load Balancer
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.0.0" # Updated to the latest version

  name    = "three-tier-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [module.security_group.security_group_id]

  listeners = [{
    port          = 80
    protocol      = "HTTP"
    action_type   = "fixed-response"
    fixed_response = {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }]
}

# EC2 Instances for Application Tier
module "app_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.0.0" # Updated to the latest version

  name           = "three-tier-app-instance"
  ami            = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (update as needed)
  instance_type  = "t2.micro"
  subnet_id      = module.vpc.private_subnets[0]
  vpc_security_group_ids = [module.security_group.security_group_id]

  tags = {
    Name = "Three-Tier-App-Instance"
  }
}

# RDS for Database Tier
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.0.0"

  identifier           = "three-tier-db"
  engine               = "mysql"
  engine_version       = "8.0"
  major_engine_version = "8.0"     # Required for option group
  family               = "mysql8.0" # Required for parameter group
  
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = "admin"
  password             = "ChangeMe123!" # Consider using AWS Secrets Manager

  vpc_security_group_ids = [module.security_group.security_group_id]
  subnet_ids             = module.vpc.private_subnets
  publicly_accessible    = false
  skip_final_snapshot    = true

  # Recommended additional parameters
  multi_az               = false    # Set to true for production
  storage_encrypted      = true     # Enable encryption at rest
  deletion_protection    = false    # Set to true for production
}