#!/bin/bash

su -l postgres -c "createuser -S -R -l -d -U postgres digick"

su  -l postgres -c "createdb -O digick digick"

su -l postgres -c "cd /home/bayco/digicheck/sql/; psql -f layout.sql digick"


