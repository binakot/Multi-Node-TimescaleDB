#!/bin/sh
set -e

# https://docs.timescale.com/timescaledb/latest/how-to-guides/configuration/timescaledb-config/#timescaledb-last-tuned-string
# https://docs.timescale.com/timescaledb/latest/how-to-guides/multi-node-setup/required-configuration/

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
# To achieve good query performance you need to enable partition-wise aggregation on the access node. This pushes down aggregation queries to the data nodes.
# https://www.postgresql.org/docs/12/runtime-config-query.html#enable_partitionwise_aggregate
sed -ri "s!^#?(enable_partitionwise_aggregate)\s*=.*!\1 = on!" /home/postgres/pgdata/data/postgresql.conf
grep "enable_partitionwise_aggregate" /home/postgres/pgdata/data/postgresql.conf
# JIT should be set to off on the access node as JIT currently doesn't work well with distributed queries.
# https://www.postgresql.org/docs/12/runtime-config-query.html#jit
sed -ri "s!^#?(jit)\s*=.*!\1 = off!" /home/postgres/pgdata/data/postgresql.conf
grep "jit" /home/postgres/pgdata/data/postgresql.conf

# Enable PostGIS extension
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL

CREATE EXTENSION IF NOT EXISTS postgis CASCADE;
CREATE EXTENSION IF NOT EXISTS postgis_topology CASCADE;

EOSQL

echo "Waiting for data nodes..."
until PGPASSWORD=$POSTGRES_PASSWORD psql -h pg_data_node_1 -U "$POSTGRES_USER" -c '\q'; do
    sleep 5s
done
until PGPASSWORD=$POSTGRES_PASSWORD psql -h pg_data_node_2 -U "$POSTGRES_USER" -c '\q'; do
    sleep 5s
done

echo "Connect data nodes to cluster and create distributed hypertable..."
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" <<-EOSQL

CREATE TABLE telemetries
(
    imei        TEXT                     NOT NULL,
    time        TIMESTAMPTZ              NOT NULL,
    latitude    DOUBLE PRECISION         NOT NULL,
    longitude   DOUBLE PRECISION         NOT NULL,
    geography   GEOGRAPHY(POINT, 4326)   NOT NULL,
    speed       SMALLINT                 NOT NULL,
    course      SMALLINT                 NOT NULL,

    CONSTRAINT telemetries_pkey PRIMARY KEY (imei, time)
);

SELECT * FROM add_data_node('data_node_1', host => 'pg_data_node_1');
SELECT * FROM add_data_node('data_node_2', host => 'pg_data_node_2');

SELECT * FROM create_distributed_hypertable(
    'telemetries', 'time', 'imei',
    number_partitions => 2, chunk_time_interval => INTERVAL '7 days', replication_factor => 1
);

EOSQL
