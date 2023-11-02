#!/bin/bash
DUMP_FILE=/backup_$(date +%Y%m%d_%H%M%S)
PGPASSWORD=$POSTGRES_PASSWORD pg_dump -d $POSTGRES_DB -U $POSTGRES_USER -h $POSTGRES_HOST -v -f ${DUMP_FILE}.pgdump
tar -czvf ${DUMP_FILE}.tar.gz ./${DUMP_FILE}.pgdump
echo "Uploading {$DUMP_FILE}.tar.gz to daily backups..."
aws s3 cp ${DUMP_FILE}.tar.gz s3://$S3_BUCKET/daily/$S3_DIR/
if [ $(date +%u) == 7 ]; then
  echo "Uploading {$DUMP_FILE}.tar.gz to weekly backups..."
	aws s3 cp ${DUMP_FILE}.tar.gz s3://$S3_BUCKET/weekly/$S3_DIR/
fi
