#!/bin/sh

mkdir -p /data/postgres/digick

chown -R postgres:postgres /data/postgres

su -l postgres -c "createuser -S -R -l -d -U postgres digick"

su -l postgres -c "echo 'CREATE TABLESPACE storage LOCATION \"/data/postgres/digick\"' | psql -U postgres"

su  -l postgres -c "createdb -D storage -O digick digick"

su -l postgres -c "cd /home/bayco/digicheck/sql/; psql -U digick -f ./layout.sql digick"


## incluir en pg_ident.conf
## digicheck bayco digick
## digicheck root digick
## digicheck postgres digick

## modificar pg_hba.conf
## host all all ident map=digicheck




