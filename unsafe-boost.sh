#!/bin/sh
set -e

# Unsafe performance for development purpose
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
sed -ri "s!^#?(fsync)\s*=.*!\1 = off!" /home/postgres/pgdata/data/postgresql.conf
grep "fsync = " /home/postgres/pgdata/data/postgresql.conf
sed -ri "s!^#?(synchronous_commit)\s*=.*!\1 = off!" /home/postgres/pgdata/data/postgresql.conf
grep "synchronous_commit = " /home/postgres/pgdata/data/postgresql.conf
sed -ri "s!^#?(work_mem)\s*=.*!\1 = 32MB!" /home/postgres/pgdata/data/postgresql.conf
grep "work_mem = " /home/postgres/pgdata/data/postgresql.conf
