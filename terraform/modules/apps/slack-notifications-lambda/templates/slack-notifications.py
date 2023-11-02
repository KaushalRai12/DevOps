import urllib3
import json
import os
http = urllib3.PoolManager()

def lambda_handler(event, context):
    url =  os.environ['slack_url']

    json_message = json.loads(event['Records'][0]['Sns']['Message'])
    region = event['Records'][0]['EventSubscriptionArn'].split(':')[3]
    if (json_message['NewStateValue'] == 'ALARM'):
        icon = ':bangbang:'
        color = "#a6364f"
    else:
        icon = ':white_check_mark:'
        color = "#32CD32"

    try:
        namespace = json_message['Trigger']['Namespace']
    except KeyError:
        namespace = "AWS"    

    msg = {
        "channel": "#cloud-watch-alarms",
        "username": "CloudWatch",
        "text": '{} CloudWatch Alarm: *{}* in {}{}'.format(icon, json_message['AlarmName'], json_message['NewStateValue'], icon),
        "attachments": [{
            "fallback": json_message['NewStateReason'],
            "text": '*{} {}*\n{}'.format(namespace, json_message['Trigger']['MetricName'], json_message['NewStateReason']),
            "color": color,
            "title": '{} - {}'.format(json_message['AlarmName'], json_message['NewStateValue']),
            "title_link": 'https://console.aws.amazon.com/cloudwatch/home?region={}#alarm:alarmFilter=ANY;name={}'.format(region, json_message['AlarmName']),
        }],
        "icon_emoji": "bell"
    }

    encoded_msg = json.dumps(msg).encode('utf-8')
    resp = http.request('POST',url, body=encoded_msg)
    print({
        "message": json_message['AlarmName'],
        "status_code": resp.status,
        "response": resp.data
    })
