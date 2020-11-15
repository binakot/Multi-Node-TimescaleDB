#!/bin/sh
set -e

# It is necessary to change the parameter max_prepared_transactions to a non-zero value
# if it hasn't been changed already ('150' is recommended).
# https://www.postgresql.org/docs/12/runtime-config-resource.html#max_prepared_transactions
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
sed -ri "s!^#?(max_prepared_transactions)\s*=.*!\1 = 150!" /var/lib/postgresql/data/postgresql.conf
grep "max_prepared_transactions" /var/lib/postgresql/data/postgresql.conf

# Enable PostGIS extension
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL

CREATE EXTENSION IF NOT EXISTS postgis CASCADE;
CREATE EXTENSION IF NOT EXISTS postgis_topology CASCADE;

EOSQL
