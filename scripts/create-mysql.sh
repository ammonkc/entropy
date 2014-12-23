#!/usr/bin/env bash

DB=$1;
SQL=$2;
mysql -uentropy -psecret -e "DROP DATABASE IF EXISTS $DB";
mysql -uentropy -psecret -e "CREATE DATABASE $DB";

unless $2.nil? || $2 == ""
    mysql -uentropy -psecret $1 < $2;
end

