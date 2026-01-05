#!/bin/bash
set -e

# ---- CONFIG ----
SITE_NAME=${SITE_NAME:-hrms.railway}

# ---- PATH FIX ----
export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

cd /workspace

echo "▶ Checking bench..."
if [ ! -d "frappe-bench" ]; then
  echo "▶ Initializing bench..."
  bench init frappe-bench --skip-redis-config-generation
fi

cd frappe-bench

echo "▶ Configuring DB & Redis..."
bench set-mariadb-host "$DB_HOST"
bench set-redis-cache-host "$REDIS_CACHE"
bench set-redis-queue-host "$REDIS_QUEUE"
bench set-redis-socketio-host "$REDIS_SOCKETIO"

sed -i '/redis/d' Procfile
sed -i '/watch/d' Procfile

echo "▶ Checking apps..."
[ ! -d "apps/erpnext" ] && bench get-app erpnext
[ ! -d "apps/hrms" ] && bench get-app hrms

echo "▶ Checking site..."
if [ ! -d "sites/$SITE_NAME" ]; then
  bench new-site "$SITE_NAME" \
    --admin-password "$ADMIN_PASSWORD" \
    --db-host "$DB_HOST" \
    --db-port "$DB_PORT" \
    --db-name "$DB_NAME" \
    --db-user "$DB_USER" \
    --db-password "$DB_PASSWORD"

  bench --site "$SITE_NAME" install-app erpnext
  bench --site "$SITE_NAME" install-app hrms
  bench --site "$SITE_NAME" enable-scheduler
fi

bench use "$SITE_NAME"
bench --site "$SITE_NAME" clear-cache

echo "▶ Starting bench..."
exec bench start
