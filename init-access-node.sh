#!/bin/sh
set -e

# To achieve good query performance you need to enable partitionwise aggregation, at least on the access node.
# This pushes down aggregation queries to the data nodes.
# https://www.postgresql.org/docs/12/runtime-config-query.html#enable_partitionwise_aggregate
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
sed -ri "s!^#?(enable_partitionwise_aggregate)\s*=.*!\1 = on!" /var/lib/postgresql/data/postgresql.conf
grep "enable_partitionwise_aggregate" /var/lib/postgresql/data/postgresql.conf

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

SELECT * FROM create_distributed_hypertable('telemetries', 'time', 'imei', chunk_time_interval => INTERVAL '1 week', replication_factor => 1);

EOSQL
