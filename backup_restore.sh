#!/bin/bash
# Restore script for resetting and restoring the "pretix" database from an SQL dump.
# Usage: ./restore.sh dump_file.sql

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 dump_file.sql" >&2
  exit 1
fi

DUMP_FILE="$1"

# Check if the dump file exists and is not empty
if [ ! -f "$DUMP_FILE" ]; then
  echo "Error: Dump file '$DUMP_FILE' does not exist." >&2
  exit 1
fi

if [ ! -s "$DUMP_FILE" ]; then
  echo "Error: Dump file '$DUMP_FILE' is empty!" >&2
  exit 1
fi

echo "Stopping pretix"


docker compose stop app

echo "Resetting the 'pretix' database..."

# Execute commands inside the "database" container to drop and recreate the database.
# We connect to the default 'postgres' database because we cannot drop the database we are connected to.
docker exec -i database psql -U pretix -d postgres <<EOF
DROP DATABASE IF EXISTS pretix;
CREATE DATABASE pretix WITH OWNER pretix;
EOF

if [ $? -ne 0 ]; then
  echo "Error: Failed to reset the database." >&2
  exit 1
fi

echo "Database reset successfully. Starting restoration..."

# Restore the dump into the freshly created 'pretix' database.
cat "$DUMP_FILE" | docker exec -i database psql -U pretix -d pretix

if [ $? -ne 0 ]; then
  echo "Error: SQL dump restoration failed." >&2
  exit 1
fi

echo "Database restored successfully from '$DUMP_FILE'."

echo "start pretix"
docker compose start app

exit 0

