#!/bin/bash

HISTORY=${1-pumphistory.json}
OUTPUT=${2-pumphistory.ns.json}
#TZ=${3}

cat $HISTORY | \
  json -e "this.medtronic = this._type;" | \
  #json -e "this.dateString = this.timestamp + '$(TZ=TZ date +%z)'" | \
  json -e "this.dateString = this.timestamp + '$(date +%z)'" | \
  json -e "this.type = 'medtronic'" | \
  json -e "this.date = this.date ? this.date : new Date(Date.parse(this.dateString)).getTime( )" \
  > $OUTPUT


# requires API_SECRET and site to be set in calling environment (i.e. in crontab)
curl -X POST --data-binary @$OUTPUT -H "API-SECRET: $API_SECRET" -H "content-type: application/json" $site/api/v1/entries.json && touch /tmp/openaps.online || echo "Unable to upload to $site."
