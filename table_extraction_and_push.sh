#!/bin/bash
set -e

# ========== CONFIG ==========
KEYSPACE="journal_entry_sync"
TABLES=("journal_entry" "ledger_account")
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REPO_PATH="/home/azureuser/fusse-data-extraction"
DATA_DIR="${REPO_PATH}/data"
CONTAINER_NAME="cass_test"   # 👈 change if your container has a different name

# ========== PREPARE ==========
cd "$REPO_PATH"
mkdir -p "$DATA_DIR"

# ========== EXPORT ==========
for TABLE in "${TABLES[@]}"; do
    CSV_FILENAME="${TABLE}_${TIMESTAMP}.csv"
    CSV_PATH="${DATA_DIR}/${CSV_FILENAME}"
    HOST_PATH="${DATA_DIR}/${CSV_FILENAME}"

    echo "Exporting $KEYSPACE.$TABLE to container path $CONTAINER_PATH..."
    docker exec "$CONTAINER_NAME" cqlsh -e "COPY ${KEYSPACE}.${TABLE} TO '${CONTAINER_PATH}' WITH HEADER = TRUE;"

    echo "Copying file from container to host..."
    docker cp "$CONTAINER_NAME":"$CONTAINER_PATH" "$HOST_PATH"
done

# ========== GIT ==========
git add data/*.csv
git commit -m "Automated CSV export ${TIMESTAMP}"
git push origin main

echo "Export and push completed at ${TIMESTAMP}"
