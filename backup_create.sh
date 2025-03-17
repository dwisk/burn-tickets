#!/bin/bash
# Backup script to create an SQL dump from a running Postgres container

# Create a timestamped filename for the SQL dump
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backups/db_backup_${TIMESTAMP}.sql"

echo "Creating SQL dump from the 'database' container..."
# Execute pg_dump inside the running container named "database"
docker exec -t database pg_dump --clean -U pretix pretix > "$BACKUP_FILE"
if [ $? -ne 0 ]; then
  echo "Error: SQL dump creation failed." >&2
  # If you stopped any services above, you may want to restart them here.
  # docker compose start <service_name>
  exit 1
fi

# Verify the SQL dump file is not empty
if [ ! -s "$BACKUP_FILE" ]; then
  echo "Error: SQL dump file ${BACKUP_FILE} is empty!" >&2
  # Restart any stopped services if necessary
  # docker compose start <service_name>
  exit 1
fi

echo "SQL dump created successfully: ${BACKUP_FILE}"

echo "Backup process completed successfully."
exit 0

