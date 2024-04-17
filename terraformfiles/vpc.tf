module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "${var.prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a"]
  private_subnets = ["10.0.2.0/24"]
  public_subnets  = ["10.0.0.0/24"]

  enable_nat_gateway = true
}
resource "aws_eip" "nginx-plus-0" {
  instance = aws_instance.nginx-plus.0.id
  vpc      = true
}
resource "aws_eip" "nginx-plus-1" {
  instance = aws_instance.nginx-plus.1.id
  vpc      = true
}
resource "aws_security_group" "f5" {
  name        = "${var.prefix}-f5"
  description = "Allow inbound SSH and HTTPS traffic from my IP"
  vpc_id      = module.vpc.vpc_id # Specify the VPC ID here
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_from] # Replace with your laptop's public IP
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allow_from] # Replace with your laptop's public IP
  }

 ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allow_from] # Replace with your laptop's public IP
  }

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
