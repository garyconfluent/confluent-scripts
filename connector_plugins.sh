#!/bin/bash
# @Author: Scott Stroud

start=`date +%s`

# Array of Connector Names (strings) that you care about

connectors=(
   "kafka-connect-ibmmq"
   "snowflake-kafka-connector"
   "kafka-connect-replicator"
   "kafka-connect-servicenow"
   "kafka-connect-json-schema"
   "kafka-connect-salesforce"
   "kafka-connect-s3-source"
)
# output format that jq will produce (each entry on seperate line)
# output_format=".name + \":\" + .version + \" - Release Date: \" + .release_date"
output_format="[.name,.version,.release_date]|@csv"
# curl the manis and then sort then by release_date desc and save it to allmanis.json
curl -s -S 'https://api.hub.confluent.io/api/plugins?per_page=100000' | jq '. | sort_by(.release_date) | reverse | .' > allmanis.json

# Hack to create a comma-seperated, double quote escaped string from the array to feed jq 'IN'
connectors_string=""
delim=""
for conn in "${connectors[@]}"; do
  connectors_string="$connectors_string$delim\"$conn\""
  delim=","
done

# filter allmanis.json for just these connectors (maintaining the sort of release_date desc)
echo "Latest Connector Versions as of $(date '+%F %T')"
echo "#####################################################"  
echo "name____________________,version,release date" | column -t -s ","
jq -r '.[] | select(IN(.name; '"${connectors_string}"')) | '"${output_format}"'' allmanis.json |tr -d '"'|column -t -s ","

# rm allmanis.json

end=`date +%s`
duration=$((end-start))