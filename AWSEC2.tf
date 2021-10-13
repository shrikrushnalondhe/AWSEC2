module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = toset(["one", "two", "three"])

  name = "instance-${each.key}"

  ami                    = "ami-041d6256ed0f2061c"
  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = ["sg-8f248bf0"]
  subnet_id              = "subnet-f8a85a93"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}