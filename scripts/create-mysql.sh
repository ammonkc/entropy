#!/usr/bin/env bash

DB=$1;
mysql -uentropy -psecret -e "DROP DATABASE IF EXISTS \`$DB\`";
mysql -uentropy -psecret -e "CREATE DATABASE \`$DB\` DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci";

if [[ $2 ]]; then
    mysql -uentropy -psecret $1 < $2;
fi

