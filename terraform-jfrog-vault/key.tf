resource "tls_private_key" "lab_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "lab_key" {
  key_name   = "jfrog-vault-key"
  public_key = tls_private_key.lab_key.public_key_openssh
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.lab_key.private_key_pem
  filename        = "${path.module}/jfrog-vault-key.pem"
  file_permission = "0400"
}