#!/bin/bash
DUMP_FILE=$1
POSTGRES_HOST=$2
echo "Downloading {$DUMP_FILE}.tar.gz from daily backups..."
aws s3 cp s3://$S3_BUCKET/daily/$S3_DIR/${DUMP_FILE}.tar.gz .
tar -xzf ${DUMP_FILE}.tar.gz
PGPASSWORD=$POSTGRES_PASSWORD psql -d $POSTGRES_DB -U $POSTGRES_USER -h $POSTGRES_HOST < ./${DUMP_FILE}.pgdump
