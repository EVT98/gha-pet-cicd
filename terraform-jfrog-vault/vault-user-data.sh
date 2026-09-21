#!/bin/bash
set -eux

dnf update -y
dnf install -y docker jq

systemctl enable docker
systemctl start docker

docker pull hashicorp/vault:latest

docker run -d \
  --name vault \
  --restart unless-stopped \
  --cap-add=IPC_LOCK \
  -e VAULT_DEV_ROOT_TOKEN_ID="${vault_root_token}" \
  -e VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200 \
  -p 8200:8200 \
  hashicorp/vault:latest

# Wait until Vault is actually ready
until curl -s http://127.0.0.1:8200/v1/sys/health > /dev/null; do
  echo "Waiting for Vault..."
  sleep 2
done

# Enable AppRole
docker exec \
  -e VAULT_ADDR=http://127.0.0.1:8200 \
  -e VAULT_TOKEN="${vault_root_token}" \
  vault vault auth enable approle

# Create AppRole for CI/CD
docker exec \
  -e VAULT_ADDR=http://127.0.0.1:8200 \
  -e VAULT_TOKEN="${vault_root_token}" \
  vault vault write auth/approle/role/github-actions \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=24h

# Get Role ID
ROLE_ID=$(docker exec \
  -e VAULT_ADDR=http://127.0.0.1:8200 \
  -e VAULT_TOKEN="${vault_root_token}" \
  vault vault read \
  -field=role_id \
  auth/approle/role/github-actions/role-id)

# Generate Secret ID
SECRET_ID=$(docker exec \
  -e VAULT_ADDR=http://127.0.0.1:8200 \
  -e VAULT_TOKEN="${vault_root_token}" \
  vault vault write \
  -field=secret_id \
  -force \
  auth/approle/role/github-actions/secret-id)

echo "$ROLE_ID" > /home/ec2-user/vault-role-id
echo "$SECRET_ID" > /home/ec2-user/vault-secret-id

chmod 600 /home/ec2-user/vault-role-id
chmod 600 /home/ec2-user/vault-secret-id

chown ec2-user:ec2-user /home/ec2-user/vault-role-id
chown ec2-user:ec2-user /home/ec2-user/vault-secret-id