#! /usr/bin/env bash
set -e
## write Teams Webhook from env variable
export DATASOURCES_PATH="/elastalert/rules/static_rules"
for file in ${DATASOURCES_PATH}/heartbeat_rules/*
    do
        echo $file
        if [ -d $file ] ; then
            continue;
        else
            sed -i "s,ms_teams_webhook_url.*,ms_teams_webhook_url: ${TEAMS_LOG_HEARTBEAT_WEBHOOK},g" $file || true
        fi
    done
for file in ${DATASOURCES_PATH}/error_rules/*/*
    do
        if [ -d $file ] ; then
            continue;
        else
            sed -i "s,ms_teams_webhook_url.*,ms_teams_webhook_url: ${TEAMS_LOG_ALERT_WEBHOOK},g" $file || true
        fi
    done

for file in ${DATASOURCES_PATH}/event_rules/*/*
    do
        if [ -d $file ] ; then
            continue;
        else
            sed -i "s,ms_teams_webhook_url.*,ms_teams_webhook_url: ${TEAMS_LOG_ALERT_WEBHOOK},g" $file || true
        fi
    done



echo "run save object";
timeout 600 bash -c 'while [ $(curl -s -o /dev/null -w "%{http_code}" -XGET http://logmon-kibana:5601/status) !=  "200" ]; do sleep 1;done' || false ;
curl --location --request POST 'http://logmon-kibana:5601/api/saved_objects/index-pattern/*?overwrite=True' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: text/plain' \
    --data-raw '{
        "attributes": {
            "title": "*",
            "timeFieldName": "@timestamp"
        }
    }' || true ;
curl --location --request POST 'http://logmon-kibana:5601/api/saved_objects/index-pattern/logstash*?overwrite=True' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: text/plain' \
    --data-raw '{
        "attributes": {
            "title": "logstash*",
            "timeFieldName": "@timestamp"
        }
    }' || true ;
curl --location --request POST 'http://logmon-kibana:5601/api/saved_objects/index-pattern/elastalert*?overwrite=True' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: text/plain' \
    --data-raw '{
        "attributes": {
            "title": "elastalert*",
            "timeFieldName": "@timestamp"
        }
    }' || true ;
curl --location --request POST 'http://logmon-kibana:5601/api/saved_objects/index-pattern/winlogbeat*?overwrite=True' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: text/plain' \
    --data-raw '{
        "attributes": {
            "title": "winlogbeat*",
            "timeFieldName": "@timestamp"
        }
    }' || true ;
curl --location --request POST 'http://logmon-kibana:5601/api/kibana/settings/defaultIndex?overwrite=True' \
    --header 'kbn-xsrf: reporting' \
    --header 'Content-Type: application/json' \
    --data-raw '{
        "value": "*"
    }' || true ;
echo "run save object succeed";


echo "Run elastalert"
elastalert-create-index --config /elastalert/elastalert.config.yaml || true;
elastalert --config /elastalert/elastalert.config.yaml --verbose || exit 1;

