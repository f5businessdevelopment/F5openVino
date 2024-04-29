resource "aws_instance" "nginx-plus" {
  count                  = 2
  ami                    = "ami-0f40f091219a2e61f"
  instance_type          = "c5.large"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.f5.id]
  iam_instance_profile   = aws_iam_instance_profile.scsprofile.name
  key_name               = aws_key_pair.demo.key_name
  tags = {
    Name = "${var.prefix}-nginxplus-${count.index}"
    Env  = "scs-env"
  }
}

resource "aws_eip" "nginx-plus" {
  count = 2
  instance = aws_instance.nginx-plus[count.index].id
  domain   = "vpc"
}


output "To_SSH_nginx-plus" {
  value = [
    "ssh -i ${aws_key_pair.demo.key_name}.pem ec2-user@${aws_instance.nginx-plus[0].public_ip}",
    "ssh -i ${aws_key_pair.demo.key_name}.pem ec2-user@${aws_instance.nginx-plus[1].public_ip}"
  ]
}
