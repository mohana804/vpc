
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


resource "aws_instance" "PublicWebTemplate" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-webtier-subnet-1.id
  vpc_security_group_ids = [aws_security_group.webserver-security-group.id]
  key_name               = "keypair"
  user_data = file("${path.module}/apache.sh")

  tags = {
    Name = "webtier-instance"
  }
}





resource "aws_instance" "private-app-template" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private-apptier-subnet-1.id
  vpc_security_group_ids = [aws_security_group.ssh-security-group.id]
  key_name               = "keypair"

  tags = {
    Name = "apptier-instance"
  }
}





