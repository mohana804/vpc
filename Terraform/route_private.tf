
### Private Route Table ###

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc_test.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "vpc-test-Private Route Table"
  }
}

resource "aws_route_table_association" "nat_route_1" {
  subnet_id      = aws_subnet.private-apptier-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "nat_route_2" {
  subnet_id      = aws_subnet.private-apptier-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}



resource "aws_route_table_association" "nat_route_db_1" {
  subnet_id      = aws_subnet.private-database-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}


resource "aws_route_table_association" "nat_route_db_2" {
  subnet_id      = aws_subnet.private-database-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}