resource "aws_instance" "vault" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type_vault
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  key_name = aws_key_pair.lab_key.key_name
  
  vpc_security_group_ids = [
    aws_security_group.vault.id
  ]

  user_data = file("vault-user-data.sh")

  tags = {
    Name = "vault-lab"
  }
}