#!/usr/bin/env bash

DB=$1;
mysql -uentropy -psecret -e "DROP DATABASE IF EXISTS $DB";
mysql -uentropy -psecret -e "CREATE DATABASE $DB";
