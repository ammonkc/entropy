#!/usr/bin/env bash

DB=$1;
su postgres -c "dropdb $DB --if-exists"
su postgres -c "createdb -O entropy '$DB' || true"

if [[ $2 ]]; then
    su postgres -c "psql -U postgres $1 < $2"
fi
