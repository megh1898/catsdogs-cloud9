# aws provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

#Fetch Amazon AMI
data "aws_ami" "ami-amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get VPC id for  VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_default_subnet" "default" {
  availability_zone = "us-east-1a"
  tags = {
    Name = "Default subnet for us-east-1"
  }
}

# Create Amazon Linux ec2 in a  VPC
resource "aws_instance" "linux_mchine" {
  ami                    = data.aws_ami.ami-amzn2.id
  key_name               = aws_key_pair.key-megh.key_name
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.sg01.id]
  user_data = "${file("dockerimage.sh")}"
  tags = {
    Name = "Linux-Machine"
    }
}

resource "aws_security_group" "sg01" {
  name        = "allow_http_conn"
  description = "Allow http inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "Http"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "Http"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_http"
  }
}

# Adding SSH key to ec2 instance
resource "aws_key_pair" "key-megh" {
  key_name   = "key-megh"
  public_key = file("key-megh.pub")
}

resource "aws_ecr_repository" "clo835-assignment1" {
  name                 = "clo835-assignment1"
  image_tag_mutability = "MUTABLE"
}