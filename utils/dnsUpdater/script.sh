#!/bin/bash

source .env

STORED_IP=$([[ -f data/ipstored ]] && cat data/ipstored)
echo Saved IP: $STORED_IP

PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
if [[ $STORED_IP != $PUBLIC_IP ]]
then
  OUTPUT=$(wget --quiet \
    --method PUT \
    --timeout=0 \
    --header 'Content-Type: application/json' \
    --header="Authorization: Bearer $TOKEN" \
    --body-data="{
      \"id\": \"$DNS_RECORD\",
      \"type\": \"$RECORD_TYPE\",
      \"name\": \"$RECORD_NAME\",
      \"content\": \"$PUBLIC_IP\",
      \"proxiable\": $RULE_PROXIABLE,
      \"proxied\": $RULE_PROXIED,
      \"ttl\": 1,
      \"locked\": $RULE_LOCKED,
      \"zone_id\": \"$ZONE_ID\",
      \"zone_name\": \"$ZONE_NAME\",
      \"meta\": {
          \"auto_added\": false,
          \"managed_by_apps\": false,
          \"managed_by_argo_tunnel\": false
      }
  }" \
     -O - "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD")

  echo "OUTPUT: $OUTPUT"
  IP_UPDATED=$(echo $OUTPUT | jq -r '.result.content')

  RESULT=$(echo $OUTPUT | jq -r '.success')
  echo "RESULT: $RESULT"
  if [[ $RESULT == 'true' ]]
  then
    mkdir -p data && echo $IP_UPDATED > data/ipstored
    if [[ -z "$SEND_TELEGRAM_MESSAGE" ]]
    then
      echo IP UPDATED TO $IP_UPDATED
    else
      curl "https://api.telegram.org/$QUERY&text=CLUSTER IP UPDATED TO $IP_UPDATED"
    fi
  else
    echo There was an error updating to $PUBLIC_IP
  fi
fi