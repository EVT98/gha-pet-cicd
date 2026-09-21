variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type_jfrog" {
  description = "EC2 instance type for JFrog"
  type        = string
  default     = "t3.large"
}

variable "instance_type_vault" {
  description = "EC2 instance type for Vault"
  type        = string
  default     = "t3.micro"
}

variable "vault_root_token" {
  description = "Initial Vault root token - LAB ONLY"
  type        = string
  sensitive   = true
  default     = "root"
}