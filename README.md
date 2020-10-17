# Multi-Node-TimescaleDB

A multi-node setup of TimescaleDB 🐯🐯🐯 🐘 🐯🐯🐯

## How to run

```bash
# Run app stack
$ docker-compose up -d

# Stop app stack and remove volumes
$ docker-compose down --volumes
```

`PgAdmin` is available on [http://localhost:5433](http://localhost:5433) with `admin@admin.com` / `admin`.

Just add new connection in `GUI with settings: 

```text
host: postgres
port: 5432
username: postgres
password: postgres
```

## Useful links

* [TimescaleDB Docs: Single Node vs. Multi-Node](https://docs.timescale.com/v2.0/introduction/architecture#single-node-vs-clustering)

* [TimescaleDB Docs: Set up multi-node TimescaleDB](https://docs.timescale.com/v2.0/getting-started/setup-multi-node-basic#basic-multi-node-setup)

* [TimescaleDB Docs: Tutorial: Scaling out TimescaleDB](https://docs.timescale.com/v2.0/tutorials/clustering)

* [TimescaleDB Docs: Installation via Docker](https://docs.timescale.com/latest/getting-started/installation/docker/installation-docker)

* [TimescaleDB GitHub: Examples](https://github.com/timescale/examples)

* [TimescaleDB DockerHub: Docker image](https://hub.docker.com/r/timescale/timescaledb)
