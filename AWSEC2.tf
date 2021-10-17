provider "aws" {
  region = "us-east-1"
}

## Create VPC ##
resource "aws_vpc" "terraform-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-demo-vpc"
  }
}

output "aws_vpc_id" {
  value = "${aws_vpc.terraform-vpc.id}"
}

## Security Group##
resource "aws_security_group" "terraform_private_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id      = "${aws_vpc.terraform-vpc.id}"
  name        = "terraform_ec2_private_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
  }
  
  egress {
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "ec2-private-sg"
  }
}

output "aws_security_gr_id" {
  value = "${aws_security_group.terraform_private_sg.id}"
}

## Create Subnets ##
resource "aws_subnet" "subnet_dev" {
  vpc_id     = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet_dev"
  }
}
output "aws_subnet_subnet_dev" {
  value = "${aws_subnet.subnet_dev.id}"
}

resource "aws_subnet" "subnet_prod" {
  vpc_id     = "${aws_vpc.terraform-vpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet_prod"
  }
}

output "aws_subnet_subnet_prod" {
  value = "${aws_subnet.subnet_prod.id}"
}

resource "aws_instance" "dev" {
    ami = "ami-02e136e904f3da870"
    instance_type = "t2.micro"
   key_name = "aws_key"
    vpc_security_group_ids =  [ "${aws_security_group.terraform_private_sg.id}" ]
    subnet_id = "${aws_subnet.subnet_dev.id}"
  
  tags = {
    Name = "dev"
  }
  
  
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "jenkins"
      private_key = file("/home/jenkins/keys/aws_key")
      timeout     = "4m"
  
  resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGWY8SDH0GnV4FhP3gPZozofXlfEgxGYpvHmZmJYnvnxMoafvH6y8/9uKMDfM+IJirurxG42gfwfL2Y70ETa0KtEjhEnjZkc09Tri++5WvgjEiiXkr2/pxLYKbDPxEGbKRiyFOFMquHXMxvIBrId3wIpa6mNaMv4fFfWlKXr+IMWGFX4/2RfoVbpkFg+Q6ijyRiUviXS8IjUdRixDrV44wFSwCTpi2v0FqPuTEdkrE1DXIBopseCVumQsCunWRqeU5wrzeZBWhzADvjjKHhb1N56mjgLSw0m6b/xrJNjvc8qAWmkazREW43220OqdkqJYb1lqvsaXism+wksmGv8pNroot@ip-172-31-26-94.ec2.internal"
}
    count         = 1
    associate_public_ip_address = true
    tags = {
      Name              = "terraform_ec2_dev_awsdev"
      Environment       = "development"
      Project           = "DEMO-TERRAFORM"
    }
}
}

## output "instance_id_list"     { value = ["${aws_instance.terraform_wapp.*.id}"] } ##
