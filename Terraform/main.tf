provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "Three-Tier-VPC"
  cidr = "10.0.0.0/16"

  azs              = ["us-east-1a", "us-east-1b"]
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]    # Web tier
  private_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]   # App tier
  database_subnets = ["10.0.5.0/24", "10.0.6.0/24"]   # DB tier

  create_database_subnet_group = true
  enable_nat_gateway          = true
  single_nat_gateway          = true
  enable_dns_support          = true
  enable_dns_hostnames        = true

  tags = {
    Terraform   = "true"
    Environment = "production"
  }
}

# Security Groups
module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "web-tier-sg"
  description = "Security group for web tier"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules  = ["all-all"]
}

module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "app-tier-sg"
  description = "Security group for application tier"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.web_sg.security_group_id
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.web_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"

  name        = "db-tier-sg"
  description = "Security group for database tier"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.app_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]
}

# Web Tier (Auto Scaling Group with ALB)
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.0.0"

  name               = "three-tier-web-alb"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.web_sg.security_group_id]
  load_balancer_type = "application"

  target_groups = [
    {
      name_prefix      = "web-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
}

module "web_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.0"

  name          = "web-tier-asg"
  min_size      = 2
  max_size      = 4
  desired_size  = 2
  health_check_type = "ELB"
  vpc_zone_identifier = module.vpc.public_subnets
  target_group_arns   = module.alb.target_group_arns

  launch_template_name = "web-tier-lt"
  launch_template_description = "Launch template for web tier instances"
  update_default_version = true

  image_id      = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type = "t3.micro"
  security_groups = [module.web_sg.security_group_id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from Web Tier</h1>" > /var/www/html/index.html
  EOF

  tag_specifications = [
    {
      resource_type = "instance"
      tags = {
        Name = "Web-Tier-Instance"
      }
    }
  ]
}

# Application Tier
module "app_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.0.0"

  for_each = toset(["app-1", "app-2"])

  name                   = "three-tier-app-${each.key}"
  ami                    = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type          = "t3.micro"
  subnet_id              = element(module.vpc.private_subnets, index(["app-1", "app-2"], each.key))
  vpc_security_group_ids = [module.app_sg.security_group_id]

  tags = {
    Name = "Three-Tier-App-Instance-${each.key}"
  }
}

# Database Tier
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.0.0"

  identifier           = "three-tier-db"
  engine               = "mysql"
  engine_version       = "8.0"
  major_engine_version = "8.0"
  family               = "mysql8.0"
  
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = "admin"
  password             = "ChangeMe123!" # Use AWS Secrets Manager in production
  port                 = 3306

  vpc_security_group_ids = [module.db_sg.security_group_id]
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false    # Set to true for production
  storage_encrypted      = true
  deletion_protection    = false    # Set to true for production
}