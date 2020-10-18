#!/bin/sh

set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL

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

SELECT create_hypertable('telemetries', 'time');

EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" \
  -c "\COPY telemetries FROM /tmp/data/data1.csv CSV"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" \
  -c "\COPY telemetries FROM /tmp/data/data2.csv CSV"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" \
  -c "\COPY telemetries FROM /tmp/data/data3.csv CSV"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" \
  -c "\COPY telemetries FROM /tmp/data/data4.csv CSV"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" \
  -c "\COPY telemetries FROM /tmp/data/data5.csv CSV"
