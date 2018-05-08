#!/bin/bash
# set -x

sudo su - postgres -c 'dropdb --if-exists northwind'
sudo su - postgres -c 'dropuser --if-exists northwind_user'

cat << EOF | sudo su - postgres -c psql
-- Create the database user:
CREATE USER northwind_user WITH PASSWORD 'thewindisblowing';

-- Create the database:
CREATE DATABASE northwind WITH OWNER=northwind_user
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;
EOF

sudo su - postgres -c 'psql template1 -c "grant all on DATABASE northwind to northwind_user;"'
sudo su - postgres -c 'psql northwind -c "GRANT ALL on ALL tables IN SCHEMA public to northwind_user"'

sudo su - postgres -c 'psql northwind < /mnt/bootstrap/sql/northwind.sql'