output "jfrog_url" {
  description = "JFrog Artifactory URL"
  value       = "http://${aws_instance.jfrog.public_ip}:8082"
}

output "vault_url" {
  description = "Vault URL"
  value       = "http://${aws_instance.vault.public_ip}:8200"
}

output "jfrog_username" {
  value = "admin"
}

output "jfrog_initial_password" {
  value     = "password"
  sensitive = true
}

output "vault_initial_root_token" {
  value     = var.vault_root_token
  sensitive = true
}