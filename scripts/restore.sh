#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BACKUP_FILE="${1:-}"
if [[ -z "$BACKUP_FILE" ]]; then
  echo "Usage: ./scripts/restore.sh backups/<backup>.sql"
  exit 1
fi

if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "ERROR: backup file not found: $BACKUP_FILE"
  exit 1
fi

if [[ ! -f .env ]]; then
  echo "ERROR: .env not found. Copy .env.example to .env first."
  exit 1
fi

set -a
source ./.env
set +a

RESTORE_DB="${RESTORE_DB:-booking_db_restore}"

echo "Starting PostgreSQL container..."
docker compose up -d db >/dev/null

echo "Waiting for PostgreSQL..."
until docker compose exec -T db pg_isready -U "$POSTGRES_USER" -d postgres >/dev/null 2>&1; do
  sleep 2
done

echo "Recreating fresh database: $RESTORE_DB"
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres \
  -c "DROP DATABASE IF EXISTS \"$RESTORE_DB\";" \
  -c "CREATE DATABASE \"$RESTORE_DB\";"

echo "Restoring $BACKUP_FILE into $RESTORE_DB..."
docker compose exec -T db psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$RESTORE_DB" < "$BACKUP_FILE"

echo "Verifying restored data..."
docker compose exec -T db psql -U "$POSTGRES_USER" -d "$RESTORE_DB" -c \
  "SELECT 'hotel_bookings' AS table_name, COUNT(*) AS row_count FROM hotel_bookings UNION ALL SELECT 'booking_events', COUNT(*) FROM booking_events;"

echo "Restore completed successfully."
