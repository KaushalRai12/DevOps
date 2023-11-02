#!/bin/sh

# From https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Source.PostgreSQL.html
# Replication Instance
echo "host all all $REPLICATION_INSTANCE/00 md5" >> /var/lib/postgresql/data/pg_hba.conf

# # Allow replication connections from localhost, by a user with the replication privilege.
echo "host replication dms $REPLICATION_INSTANCE/00 md5" >>  /var/lib/postgresql/data/pg_hba.conf
