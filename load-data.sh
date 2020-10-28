#!/bin/sh
set -e

echo "Load sample data..."
timescaledb-parallel-copy --connection "host=pg_access_node user=postgres password=postgres db=postgres port=5432 sslmode=disable" \
    --table telemetries --file /tmp/data/data1.csv --copy-options "CSV" --workers 4 --reporting-period 15s
timescaledb-parallel-copy --connection "host=pg_access_node user=postgres password=postgres db=postgres port=5432 sslmode=disable" \
    --table telemetries --file /tmp/data/data2.csv --copy-options "CSV" --workers 4 --reporting-period 15s
timescaledb-parallel-copy --connection "host=pg_access_node user=postgres password=postgres db=postgres port=5432 sslmode=disable" \
    --table telemetries --file /tmp/data/data3.csv --copy-options "CSV" --workers 4 --reporting-period 15s
timescaledb-parallel-copy --connection "host=pg_access_node user=postgres password=postgres db=postgres port=5432 sslmode=disable" \
    --table telemetries --file /tmp/data/data4.csv --copy-options "CSV" --workers 4 --reporting-period 15s
timescaledb-parallel-copy --connection "host=pg_access_node user=postgres password=postgres db=postgres port=5432 sslmode=disable" \
    --table telemetries --file /tmp/data/data5.csv --copy-options "CSV" --workers 4 --reporting-period 15s

echo "Check cluster configuration..."
psql -v ON_ERROR_STOP=1 -h pg_access_node -U "$POSTGRES_USER" <<-EOSQL

SELECT * FROM timescaledb_information.data_nodes;
SELECT * FROM timescaledb_information.hypertables;
SELECT * FROM hypertable_detailed_size('telemetries');

EOSQL
