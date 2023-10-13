#!/bin/sh
set -e

# https://docs.timescale.com/timescaledb/latest/how-to-guides/configuration/timescaledb-config/#timescaledb-last-tuned-string
# https://docs.timescale.com/timescaledb/latest/how-to-guides/multi-node-setup/required-configuration/

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
# It is necessary to change the parameter max_prepared_transactions to a non-zero value ('150' is recommended).
# https://www.postgresql.org/docs/12/runtime-config-resource.html#max_prepared_transactions
sed -ri "s!^#?(max_prepared_transactions)\s*=.*!\1 = 150!" /home/postgres/pgdata/data/postgresql.conf
grep "max_prepared_transactions" /home/postgres/pgdata/data/postgresql.conf
# Statement timeout should be disabled on the data nodes and managed through the access node configuration if desired.
# https://www.postgresql.org/docs/12/runtime-config-client.html#statement_timeout
sed -ri "s!^#?(statement_timeout)\s*=.*!\1 = 0!" /home/postgres/pgdata/data/postgresql.conf
grep "statement_timeout" /home/postgres/pgdata/data/postgresql.conf

# Enable PostGIS extension
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL

CREATE EXTENSION IF NOT EXISTS postgis CASCADE;
CREATE EXTENSION IF NOT EXISTS postgis_topology CASCADE;

EOSQL
