#!/usr/bin/env bash

DB=$1;
SQL=$2;
mysql -uentropy -psecret -e "DROP DATABASE IF EXISTS $DB";
mysql -uentropy -psecret -e "CREATE DATABASE $DB";

unless SQL.nil?
    mysql -uentropy -psecret DB < SQL;
end

