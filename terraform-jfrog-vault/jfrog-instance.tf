resource "aws_instance" "jfrog" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type_jfrog
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  key_name = aws_key_pair.lab_key.key_name

  vpc_security_group_ids = [
    aws_security_group.jfrog.id
  ]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = file("jfrog-user-data.sh")

  tags = {
    Name = "jfrog-artifactory-lab"
  }
}