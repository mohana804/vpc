
###  Public Subnet 1 - Webtier  ###

resource "aws_subnet" "public-webtier-subnet-1" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = var.public-webtier-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 1 - Web Tier"
  }
}

###  Private Subnet 2 - Webtier  ###

resource "aws_subnet" "public-webtier-subnet-2" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = var.public-webtier-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2 - Web Tier"
  }
}

###  Private Subnet 1 - Apptier  ###

resource "aws_subnet" "private-apptier-subnet-1" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = var.private-apptier-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet 1 - App Tier"
  }
}

###  Private Subnet 2 - Apptier  ###


resource "aws_subnet" "private-apptier-subnet-2" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = var.private-apptier-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet 2 - App Tier"
  }
}


###  Private Subnet-db 1 ###

resource "aws_subnet" "private-database-subnet-1" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = var.private-database-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet 1 - Db Tier"
  }
}


###  Private Subnet-db 2  ###


resource "aws_subnet" "private-database-subnet-2" {
  vpc_id                  = aws_vpc.vpc_test.id
  cidr_block              = var.private-database-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet 2 - Db Tier"
  }
}