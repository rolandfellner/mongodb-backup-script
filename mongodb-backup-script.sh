#!/bin/bash

# setup
MONGO_HOST="localhost"
MONGO_PORT="27017"
BACKUP_DIR="/backup/mongodb"
DATE=$(date +%F)

# preparation
mkdir -p "$BACKUP_DIR/$DATE"

# check existing databases
databases=$(mongo --quiet --host "$MONGO_HOST" --port "$MONGO_PORT" --eval "db.adminCommand('listDatabases').databases.map(db => db.name).join('\n')")

# Create backup of each db separately 
for db in $databases; do
  echo "Create Backup of DB: $db"
  
  # create dup
  mongodump --host "$MONGO_HOST" --port "$MONGO_PORT" --db "$db" --out "$BACKUP_DIR/$DATE"

  # Dump to ZIP
  zip -r "$BACKUP_DIR/${db}_$DATE.zip" "$BACKUP_DIR/$DATE/$db"

  # delete source files
  rm -rf "$BACKUP_DIR/$DATE/$db"
done

# clean up daily directory if empty…
rmdir --ignore-fail-on-non-empty "$BACKUP_DIR/$DATE"

echo "Backup finished."