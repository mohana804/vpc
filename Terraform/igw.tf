
### Internet Gateway  ###


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_test.id

  tags = {
    Name = "IGW"
  }
}