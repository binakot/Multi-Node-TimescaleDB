# Multi-Node-TimescaleDB

A multi-node setup of TimescaleDB.

## How to run

```bash
# Run app stack
$ docker-compose up -d

# Stop app stack and remove volumes
$ docker-compose down --volumes
```

`PgAdmin` is available on [http://localhost:5433](http://localhost:5433) with `admin@admin.com` / `admin`.

Just add new connection in GUI with settings: 

```text
host: postgres
port: 5432
username: postgres
password: postgres
```

Example query to select some telemetry:

```sql
select * from telemetries
where imei = '000000000000001'
order by time asc
limit 100;
```

## Useful links

* [TimescaleDB Docs: Single Node vs. Multi-Node](https://docs.timescale.com/v2.0/introduction/architecture#single-node-vs-clustering)

* [TimescaleDB Docs: Set up multi-node TimescaleDB](https://docs.timescale.com/v2.0/getting-started/setup-multi-node-basic#basic-multi-node-setup)

* [TimescaleDB Docs: Tutorial: Scaling out TimescaleDB](https://docs.timescale.com/v2.0/tutorials/clustering)

* [TimescaleDB Docs: Installation via Docker](https://docs.timescale.com/latest/getting-started/installation/docker/installation-docker)

* [TimescaleDB GitHub: Examples](https://github.com/timescale/examples)

* [TimescaleDB DockerHub: Docker images](https://hub.docker.com/r/timescale/timescaledb)

## Main points

* Distributed hypertables and multi-node capabilities are currently in `BETA`. 
This feature is not meant for production use.

* TimescaleDB supports `distributing hypertables` across multiple nodes (i.e., a cluster).

* Distributed hypertable `limitations`: https://docs.timescale.com/v2.0/using-timescaledb/limitations.

* A distributed hypertable exists in a `distributed database` that consists of multiple databases stored across one or more TimescaleDB instances. 
A database that is part of a distributed database can assume the role of either an `access node` or a `data node` (but not both).

* A client connects to an `access node` database. 
You should not directly access hypertables or chunks on data nodes. 
Doing so might lead to inconsistent distributed hypertables.

* To ensure best performance, you should partition a distributed hypertable by both `time and space`.

* TimescaleDB can be elastically scaled out by simply `adding data nodes` to a distributed database.
TimescaleDB can (and will) adjust the number of space partitions as new data nodes are added.
Although existing chunks will not have their space partitions updated, the new settings will be applied to newly created chunks.

## TODOs

* Add replica to each shard.

* Migrate to TimescaleDB with PostGIS extension and add more geospatial examples. 
Good place to start: https://github.com/timescale/examples
