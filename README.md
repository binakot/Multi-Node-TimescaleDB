# Multi-Node-TimescaleDB

Demo project for an online workshop with #RuPostgresTuesday.
Check out the first part: 
[В-s02e08 Распаковка TimescaleDB 2.0. В гостях — Иван Муратов](https://www.youtube.com/watch?v=vbJCq9PhSR0&t=5395s&ab_channel=%23RuPostgres).

If you need the same project as in first part check out the branch: 
[PgTuesday_1_17.11.2020](https://github.com/binakot/Multi-Node-TimescaleDB/tree/PgTuesday_1_17.11.2020).

The second one is coming...

The main branch is under development and can be different from the video.

## About

A multi-node setup of TimescaleDB 2.0.0 RC3.

Initial cluster configuration: 
single access node (AN) and 2 data nodes (DN) with 1 week interval and replication factor 1.

## How to run

```bash
# Run app stack with external network
$ docker network create pg_cluster_network
$ docker-compose up -d
```

`PgAdmin` is available on [http://localhost:15432](http://localhost:15432) 
with `admin@admin.com` / `admin`.

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

## Workshop

### 1. Preparation

At this moment you should to have a running cluster with 1 access node and 2 data nodes.
If you didn't please look at `how to run` section and do it firstly.
Also, you need access to all nodes via `psql`, `pgAdmin` or any other way you like.

Now you can fill sample data:

```bash
$ gzip -k -d ./data/*csv.gz
$ docker exec -i pg_access_node /bin/sh < ./load-init-data.sh
```

### 2. Learning cluster configuration

Run on access node and each data nodes separately.

```sql
SELECT DISTINCT imei FROM telemetries ORDER BY imei;
SELECT count(*) FROM telemetries;
```

### 3. Querying to cluster via access node

```sql
-- Speed analytics for 1 year
SELECT
    time_bucket('30 days', time) AS bucket,
    imei,
    avg(speed) AS avg,
    max(speed) AS max
FROM telemetries
WHERE speed > 0
GROUP BY imei, bucket
ORDER BY imei, bucket;

-- Speed percentiles on all telemetries
SELECT 
    percentile_cont(0.50) WITHIN GROUP (ORDER BY speed) AS p50,
    percentile_cont(0.90) WITHIN GROUP (ORDER BY speed) AS p90,
    percentile_cont(0.99) WITHIN GROUP (ORDER BY speed) AS p99
FROM telemetries;

-- Single track points for 1 month
SELECT * FROM telemetries 
WHERE imei = '000000000000001'
AND time > '2019-09-01' AND time < '2019-10-01'
ORDER BY time ASC;

-- All tracks for 1 month
SELECT imei, ST_MakeLine(telemetries.geography::geometry ORDER BY time)::geography AS track
FROM telemetries
WHERE time > '2019-09-01' AND time < '2019-10-01'
GROUP BY imei;

-- All vehicle mileages for 1 month
WITH tracks AS (
    SELECT imei, ST_MakeLine(telemetries.geography::geometry ORDER BY time)::geography AS track
	FROM telemetries
	WHERE time > '2019-09-01' AND time < '2019-10-01'
	GROUP BY imei
)
SELECT imei, ST_Length(track) / 1000 AS kilometers
FROM tracks
GROUP BY imei, kilometers;
```

### 4. Add third data node to the cluster

Firstly run the third instance of postgres for new data node:

```bash
$ docker volume create pg_data_node_3_data
$ docker run -d \
    --name pg_data_node_3 \
    --restart=unless-stopped \
    -e "POSTGRES_DB=postgres" \
    -e "POSTGRES_USER=postgres" \
    -e "POSTGRES_PASSWORD=postgres" \
    -p 5435:5432 \
    --network pg_cluster_network \
    -v pg_data_node_3_data:/var/lib/postgresql/data \
    -v `pwd`/trust-all.sh:/docker-entrypoint-initdb.d/777_trust.sh \
    -v `pwd`/unsafe-boost.sh:/docker-entrypoint-initdb.d/888_boost.sh \
    -v `pwd`//init-data-node.sh:/docker-entrypoint-initdb.d/999_cluster.sh \
    timescale/timescaledb-postgis:2.0.0-rc3-pg12
```

Now connect a new node to the cluster running command below from the access node:

```sql
SELECT * FROM add_data_node('data_node_3', host => 'pg_data_node_3');
SELECT * FROM timescaledb_information.data_nodes;
```

Then attach new data node to the distributed hypertable:

```sql
SELECT * FROM attach_data_node('data_node_3', 'telemetries');
SELECT * FROM timescaledb_information.hypertables;
```

### 5. Add more sample data into the cluster with 3 data nodes

```bash
$ docker exec -i pg_access_node /bin/sh < ./load-more-data.sh
```

Run on access node and each data nodes separately.

```sql
SELECT DISTINCT imei FROM telemetries ORDER BY imei;
SELECT count(*) FROM telemetries;
```

### !!! TODO MORE STEPS !!!

- Correct data distribution between nodes

- Block one data node and fill more data

- Chunk compression

- Add Grafana

### N. Stop the cluster

```bash
$ docker stop pg_data_node_3
$ docker rm pg_data_node_3
$ docker volume rm pg_data_node_3_data

$ docker-compose down --volumes

$ docker network rm pg_cluster_network
```

---

## Useful links

* [TimescaleDB Blog: TimescaleDB 2.0](https://blog.timescale.com/blog/timescaledb-2-0-a-multi-node-petabyte-scale-completely-free-relational-database-for-time-series)

* [TimescaleDB Docs: Single Node vs. Multi-Node](https://docs.timescale.com/v2.0/introduction/architecture#single-node-vs-clustering)

* [TimescaleDB Docs: Set up multi-node TimescaleDB](https://docs.timescale.com/v2.0/getting-started/setup-multi-node-basic)

* [TimescaleDB Docs: Distributed Hypertables](https://docs.timescale.com/v2.0/using-timescaledb/distributed-hypertables)

* [TimescaleDB API Reference: Hypertable Management](https://docs.timescale.com/v2.0/api#hypertable-management)

* [TimescaleDB Tutorial: Scaling out TimescaleDB](https://docs.timescale.com/v2.0/tutorials/clustering)

* [TimescaleDB Tutorial: Installation via Docker](https://docs.timescale.com/v2.0/getting-started/installation/docker/installation-docker)

* [TimescaleDB DockerHub: Docker images](https://hub.docker.com/r/timescale/timescaledb)

* [TimescaleDB GitHub: Examples](https://github.com/timescale/examples)

---

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
