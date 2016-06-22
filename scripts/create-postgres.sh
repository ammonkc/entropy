#!/usr/bin/env bash

DB=$1;
# su postgres -c "dropdb $DB --if-exists"

if ! su postgres -c "psql $DB -c '\q' 2>/dev/null"; then
    su postgres -c "createdb -O entropy '$DB'"
fi

if [[ $2 ]]; then
    su postgres -c "psql -U postgres $1 < $2"
fi
