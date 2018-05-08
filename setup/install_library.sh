#!/bin/bash
# set -x

sudo su - postgres -c 'dropdb --if-exists library'
sudo su - postgres -c 'dropuser --if-exists library_user'

cat << EOF | sudo su - postgres -c psql
-- Create the database user:
CREATE USER library_user WITH PASSWORD 'library';

-- Create the database:
CREATE DATABASE library WITH OWNER=library_user
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;
EOF

sudo su - postgres -c 'psql template1 -c "grant all on DATABASE library to library_user;"'
sudo su - postgres -c 'psql library -c "GRANT ALL on ALL tables IN SCHEMA public to library_user"'

sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/schema.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/member_data.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/adult_data.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/title_data.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/item_data.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/copy_data.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/juvenile_data.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/loan_data.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/loanhist_data.sql'
sudo su - postgres -c 'psql library < /mnt/bootstrap/sql/library/reservation_data.sql'