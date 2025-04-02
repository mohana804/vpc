### Nat Gateway for Private Instances ###

resource "aws_eip" "eip_nat" {
  

  tags = {
    Name = "eip1"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_nat.id
  subnet_id     = aws_subnet.public-webtier-subnet-2.id

  tags = {
    "Name" = "Nat Gateway"
  }
}