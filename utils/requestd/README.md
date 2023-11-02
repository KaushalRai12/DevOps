# RequestD Setup

## Filebeat

Required to be running on Web01 (at least).

Config: _/etc/filebeat/filebeat.yml_ - see the same file in this folder.

Tailing the log: `sudo tail -n100 -f /var/log/filebeat/filebeat`

Restarting the service: `sudo service filebeat restart`

**Note:** Filebeat will not work without _common_pipeline_ loaded into the target elastic instance:

`PUT {{elastic-log-server}}/_ingest/pipeline/common_pipeline`. Body is _common-pipeline.json_

## RequestD

Look for RequestD docs here: http://hackerpla.net/requestd/

Entire RequestD setup is not documented here, as investigation is underway for consolidation of this info into Grafana.
Nonetheless, the filebeat pipeline (above), and the following index template will still be valid.

RequestD requires the following index template:

`PUT {{elastic-log-server}}/_template/api-logger-calls`. Body is _api-logger-calls-template.json_.

**Note:** Requires ILM policy _delete-old-logger-calls_ to be in-place; this should delete after 90 days.

