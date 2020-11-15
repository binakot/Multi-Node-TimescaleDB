# Multi-Node-TimescaleDB

A multi-node setup of TimescaleDB.

## How to run

```bash
# Run app stack
$ docker-compose up -d

# Insert sample data (firstly create trigger below!!!)
$ docker exec -i pg_access_node /bin/sh < ./load-data.sh

# Stop app stack and remove volumes
$ docker-compose down --volumes
```

`PgAdmin` is available on [http://localhost:15432](http://localhost:15432) with `admin@admin.com` / `admin`.

Just add new connections in GUI with settings: 

```text
# Access node
host: pg_access_node
port: 5432
username: postgres
password: postgres

# Data node 1
host: pg_data_node_1
port: 5433
username: postgres
password: postgres

# Data node 2
host: pg_data_node_2
port: 5434
username: postgres
password: postgres
```

PostGIS Geometry trigger:

```sql
-- Create function on every nodes
CREATE FUNCTION telemetries_geometry_trigger_func() RETURNS trigger AS
$$
BEGIN
    IF NEW.geometry IS NULL AND NEW.latitude NOTNULL AND NEW.longitude NOTNULL THEN
        NEW.geometry := ST_SetSRID(ST_Makepoint(NEW.longitude, NEW.latitude), 4326);
    END IF;
    RETURN NEW;
END
$$
LANGUAGE 'plpgsql';

-- Then create trigger on access node
CREATE TRIGGER telemetries_geometry
    BEFORE INSERT
    ON telemetries
    FOR EACH ROW
EXECUTE PROCEDURE telemetries_geometry_trigger_func();
```

Example queries:

```sql
-----------------
-- ACCESS NODE --
-----------------

-- Check that table on access node doesn't contain any rows
select count(*) from only telemetries;
select count(*) from telemetries;

-- Select some data from access node
select * from telemetries
where imei = '000000000000001'
order by time asc
limit 100;

-- Simple speed analytics
SELECT
  time_bucket('30 days', time) as bucket,
  imei,
  avg(speed) as avg,
  max(speed) as max,
  min(speed) as min
FROM
  telemetries
GROUP BY bucket, imei
ORDER BY imei;

---------------
-- DATA NODE --
---------------

-- Check which devices are stored on which data node
select distinct imei from telemetries;
```

Example views:

```sql
-- Spoiler: continuous aggregates not supported on distributed hypertables!
CREATE MATERIALIZED VIEW speed_daily
WITH (timescaledb.continuous)
AS
SELECT
  time_bucket('1 day', time) as bucket,
  imei,
  avg(speed) as avg,
  max(speed) as max,
  min(speed) as min
FROM
  telemetries
GROUP BY bucket, imei;
```

## Useful links

* [TimescaleDB Docs: Single Node vs. Multi-Node](https://docs.timescale.com/v2.0/introduction/architecture#single-node-vs-clustering)

* [TimescaleDB Docs: Set up multi-node TimescaleDB](https://docs.timescale.com/v2.0/getting-started/setup-multi-node-basic)

* [TimescaleDB Docs: Distributed Hypertables](https://docs.timescale.com/v2.0/using-timescaledb/distributed-hypertables)

* [TimescaleDB API Reference: Hypertable Management](https://docs.timescale.com/v2.0/api#hypertable-management)

* [TimescaleDB Tutorial: Scaling out TimescaleDB](https://docs.timescale.com/v2.0/tutorials/clustering)

* [TimescaleDB Tutorial: Installation via Docker](https://docs.timescale.com/v2.0/getting-started/installation/docker/installation-docker)

* [TimescaleDB DockerHub: Docker images](https://hub.docker.com/r/timescale/timescaledb)

* [TimescaleDB GitHub: Examples](https://github.com/timescale/examples)

## Main points

* Distributed hypertables and multi-node capabilities are currently in `BETA`. 
This feature is not meant for production use.

* Distributed hypertable `limitations`: https://docs.timescale.com/v2.0/using-timescaledb/limitations.

* To ensure best performance, you should partition a distributed hypertable by both `time and space`.

* A distributed hypertable exists in a `distributed database` that consists of multiple databases stored across one or more TimescaleDB instances. 
A database that is part of a distributed database can assume the role of either an `access node` or a `data node` (but not both).
While the data nodes store distributed chunks, the access node is the entry point for clients to access distributed hypertables.

* TimescaleDB supports `distributing hypertables` across multiple nodes (i.e., a cluster).
A multi-node TimescaleDB implementation consists of:
one access node to handle ingest, data routing and act as an entry point for user access;
one or more data nodes to store and organize distributed data.

* A client connects to an `access node` database. 
You should not directly access hypertables or chunks on data nodes. 
Doing so might lead to inconsistent distributed hypertables.

* TimescaleDB can be elastically scaled out by simply `adding data nodes` to a distributed database.
TimescaleDB can (and will) adjust the number of space partitions as new data nodes are added.
Although existing chunks will not have their space partitions updated, the new settings will be applied to newly created chunks.
