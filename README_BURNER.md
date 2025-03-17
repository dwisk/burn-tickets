# Burner notes

## Installation

First run with local mounted postgres fails.. `^+C` and then `docker compose up` again should work

## copy docker volume to local
if started with volume (you changed docker-compose.yml) this is how you copy the postgres data from docker-volume into local directory ./data

1. `docker compose stop`
2. copy files:

```
docker run --rm \
  -v burn-tickets_postgres_data:/from \
  -v "$(pwd)/data:/to" \
  alpine \
  sh -c "cd /from && tar cf - . | tar xf - -C /to"
```


## Backups

./backup_create.sh to create local sql dump in ./backups
./backup_restore.sh ./backups/xyz.sql to replace db 
