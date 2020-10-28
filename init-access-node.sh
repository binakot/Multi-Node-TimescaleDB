#!/bin/sh
set -e

# Allow full access
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW hba_file"
sed -i '$ d' /var/lib/postgresql/data/pg_hba.conf
echo "host all all all trust" >>/var/lib/postgresql/data/pg_hba.conf
tail -2 /var/lib/postgresql/data/pg_hba.conf
sed -ri "s!^#?(listen_addresses)\s*=.*!\1 = '*'!" /var/lib/postgresql/data/postgresql.conf
grep "listen_addresses" /var/lib/postgresql/data/postgresql.conf

# To achieve good query performance you need to enable partitionwise aggregation, at least on the access node.
# This pushes down aggregation queries to the data nodes.
sed -ri "s!^#?(enable_partitionwise_aggregate)\s*=.*!\1 = on!" /var/lib/postgresql/data/postgresql.conf
grep "enable_partitionwise_aggregate" /var/lib/postgresql/data/postgresql.conf

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
    imei        TEXT              NOT NULL,
    time        TIMESTAMPTZ       NOT NULL,
    latitude    DOUBLE PRECISION  NOT NULL,
    longitude   DOUBLE PRECISION  NOT NULL,
    speed       SMALLINT          NOT NULL,
    course      SMALLINT          NOT NULL,

    CONSTRAINT telemetries_pkey PRIMARY KEY (imei, time)
);

SELECT add_data_node('data_node_1', host => 'pg_data_node_1');
SELECT add_data_node('data_node_2', host => 'pg_data_node_2');

SELECT create_distributed_hypertable('telemetries', 'time', 'imei', chunk_time_interval => INTERVAL '1 day', replication_factor => 1);

EOSQL
