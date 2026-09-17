#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  echo "ERROR: .env not found. Copy .env.example to .env first."
  exit 1
fi

set -a
source ./.env
set +a

mkdir -p backups

echo "Starting PostgreSQL container..."
docker compose up -d db >/dev/null

echo "Waiting for PostgreSQL..."
until docker compose exec -T db pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do
  sleep 2
done

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP_FILE="backups/${POSTGRES_DB}_${TIMESTAMP}.sql"

echo "Creating backup: $BACKUP_FILE"
docker compose exec -T db pg_dump \
  --no-owner \
  --no-privileges \
  -U "$POSTGRES_USER" \
  -d "$POSTGRES_DB" > "$BACKUP_FILE"

echo "Backup completed successfully."
echo "File: $BACKUP_FILE"
