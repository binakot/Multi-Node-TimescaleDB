#!/bin/sh
set -e

# Allow full access
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW hba_file"
sed -i '$ d' /var/lib/postgresql/data/pg_hba.conf
echo "host all all all trust" >>/var/lib/postgresql/data/pg_hba.conf
tail -2 /var/lib/postgresql/data/pg_hba.conf
sed -ri "s!^#?(listen_addresses)\s*=.*!\1 = '*'!" /var/lib/postgresql/data/postgresql.conf
grep "listen_addresses" /var/lib/postgresql/data/postgresql.conf

# It is necessary to change the parameter max_prepared_transactions to a non-zero value
# if it hasn't been changed already ('150' is recommended).
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -c "SHOW config_file"
sed -ri "s!^#?(max_prepared_transactions)\s*=.*!\1 = 150!" /var/lib/postgresql/data/postgresql.conf
grep "max_prepared_transactions" /var/lib/postgresql/data/postgresql.conf
