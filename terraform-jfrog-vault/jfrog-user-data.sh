#!/bin/bash
set -eux

# ============================================================
# 1. Update system and install Docker
# ============================================================

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker


# ============================================================
# 2. Create a dedicated Docker network
# ============================================================

docker network create jfrog-network || true


# ============================================================
# 3. Create persistent directories
# ============================================================

mkdir -p /opt/jfrog/artifactory/var/etc
mkdir -p /opt/jfrog/postgres

# Artifactory container uses UID 1030
chown -R 1030:1030 /opt/jfrog/artifactory/var


# ============================================================
# 4. Start PostgreSQL
# ============================================================

docker pull postgres:16

docker run -d \
  --name postgres \
  --restart unless-stopped \
  --network jfrog-network \
  -e POSTGRES_DB=artifactory \
  -e POSTGRES_USER=artifactory \
  -e POSTGRES_PASSWORD=artifactory \
  -v /opt/jfrog/postgres:/var/lib/postgresql/data \
  postgres:16


# ============================================================
# 5. Wait for PostgreSQL
# ============================================================

until docker exec postgres pg_isready \
  -U artifactory \
  -d artifactory
do
  echo "Waiting for PostgreSQL..."
  sleep 5
done


# ============================================================
# 6. Configure Artifactory to use PostgreSQL
# ============================================================

cat > /opt/jfrog/artifactory/var/etc/system.yaml <<'EOF'
configVersion: 1

shared:
  database:
    type: postgresql
    driver: org.postgresql.Driver
    url: jdbc:postgresql://postgres:5432/artifactory
    username: artifactory
    password: artifactory
EOF

chown 1030:1030 /opt/jfrog/artifactory/var/etc/system.yaml
chmod 600 /opt/jfrog/artifactory/var/etc/system.yaml


# ============================================================
# 7. Pull Artifactory
# ============================================================

docker pull releases-docker.jfrog.io/jfrog/artifactory-oss:latest


# ============================================================
# 8. Start Artifactory
# ============================================================

docker run -d \
  --name artifactory \
  --restart unless-stopped \
  --network jfrog-network \
  -p 8081:8081 \
  -p 8082:8082 \
  -v /opt/jfrog/artifactory/var:/var/opt/jfrog/artifactory \
  releases-docker.jfrog.io/jfrog/artifactory-oss:latest