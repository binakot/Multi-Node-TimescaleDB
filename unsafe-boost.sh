#!/bin/sh
set -e

# Unsafe performance for development purpose
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
sed -ri "s!^#?(fsync)\s*=.*!\1 = off!" /var/lib/postgresql/data/postgresql.conf
grep "fsync = " /var/lib/postgresql/data/postgresql.conf
sed -ri "s!^#?(synchronous_commit)\s*=.*!\1 = off!" /var/lib/postgresql/data/postgresql.conf
grep "synchronous_commit = " /var/lib/postgresql/data/postgresql.conf
sed -ri "s!^#?(work_mem)\s*=.*!\1 = 32MB!" /var/lib/postgresql/data/postgresql.conf
grep "work_mem = " /var/lib/postgresql/data/postgresql.conf
