#!/bin/bash

su -c "createuser -S -R -l -d -U postgres digick" postgres

createdb -U digick digick

psql -f layout.sql digick digick


