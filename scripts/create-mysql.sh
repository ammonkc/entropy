#!/usr/bin/env bash

cat > ~/.my.cnf << EOF
[client]
user = entropy
password = secret
host = localhost
EOF

DB=$1;
mysql -uentropy -psecret -e "CREATE DATABASE IF NOT EXISTS \`$DB\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";

if [[ $2 ]]; then
    mysql -uentropy -psecret $1 < $2;
fi
