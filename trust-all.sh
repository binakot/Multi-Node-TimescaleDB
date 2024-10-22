#!/bin/sh
set -e

# Allow trust access to all
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW hba_file"
sed -i '$ d' /home/postgres/pgdata/data/pg_hba.conf
echo "host all all all trust" >>/home/postgres/pgdata/data/pg_hba.conf
tail -2 /home/postgres/pgdata/data/pg_hba.conf

psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
sed -ri "s!^#?(listen_addresses)\s*=.*!\1 = '*'!" /home/postgres/pgdata/data/postgresql.conf
grep "listen_addresses" /home/postgres/pgdata/data/postgresql.conf
