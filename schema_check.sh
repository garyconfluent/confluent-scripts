 #!/bin/bash 

usage() { 
	echo "
	Compares schema registry subjects against cluster topics to determine if any
	schemas do not have a topic associated with it using TopicNamingStrategy
    Requires:
	 jq - command to read json
	Usage:
	[-ru|--restUrl] Cluster REST_API_URL
	[-ra|--restApiKey] The REST API Key for cluster
	[-rs|--restApiSecret] The REST API Secret Key for cluster
	[-rc]--restClusterId] The Cluster Id]					
	[-sr|--schemaRegistryUrl] Schema Registry URL
	[-sa|--schemaRegistryAPIKey] Schema Registry API Key
	[-ss|--schemaRegistrySecretKey] Schema Registry Secret Key
	" \
	1>&2; exit 1; 
	
}

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "${e}" == "${match}" ]] && return 0; done
  return 1
}

#input_variables 
rest_url=
rest_cluster_id=
rest_api_key=
rest_api_secret=
schema_registry_url=
schema_registry_api_key=
schema_registry_api_secret=

_setArgs(){
  while [[ "${1:-}" != "" ]]; do
    case "$1" in
      "-ru" | "--restUrl")
	  	#echo "here"
        shift
        rest_url=$1
        ;;
      "-ra" | "--restAPIKey")
	    shift 
        rest_api_key=$1
        ;;	
	  "-rs" | "--restAPISecret")
	    shift 
        rest_api_secret=$1
        ;;
	  "-rc"|"--restClusterId")
	    shift
		rest_cluster_id=$1
		;;	
      "-sr" | "--schemaRegistryUrl")
	    shift 
        schema_registry_url=$1
        ;;
	  "-sa" | "--schemaRegistryAPIKey")
	    shift 
        schema_registry_api_key=$1
        ;;
	   "-ss" | "--SchemaRegistryAPISecret")
	    shift 
        schema_registry_api_secret=$1
        ;;
	   "-h"|"--help")
	     shift
	     usage
		;;
	   *)
	    echo "Invalid argument $1"
	    usage	
    esac
    shift
  done
}

# parse arguments
_setArgs $*

#Check for required arguments
ec=0
if [ -z "$rest_url" ] 
then
	echo "Parameter not specified -ru|--restUrl"
	ec=$((ec+1))
fi

if [ -z "$rest_cluster_id" ]
then 
	echo "Parameter not specified -rc|--restClusterId"
	ec=$((ec+1))
fi

if [ -z "$rest_api_key" ]
then 
    echo "Parameter not specified -ra|--restAPIKey"
    ec=$((ec+1))
fi

if [ -z "$rest_api_secret" ]
then 
     echo "Parameter not specified -rs|--restAPISecret"
     ec=$((ec+1))
fi

if [ -z "$schema_registry_url" ] 
then 
   echo "Parameter not specified -sr|--schemaRegistryUrl"
   ec=$((ec+1))
fi

if [ -z "$schema_registry_api_key" ]
then 
   echo "Parameter not specified -sa|--schemaRegistryAPIKey"
   ec=$((ec+1))
fi

if [ -z "$schema_registry_api_secret" ]
then 
	echo "Parameter not specified -ss|--schemaRegistrySecretKey"
    ec=$((ec+1))
fi

if [ "${ec}" -gt 0 ];then usage
fi

#clean up old files if they exist
if test -f "subjects_output.txt"; then
	rm subjects_output.txt
fi

if test -f "topics_output.txt"; then
	rm topics_output.txt
fi

echo "Getting Subjects from schema-registry-url to ${schema_registry_url}";
sr_connection_string="curl -s -u $schema_registry_api_key:$schema_registry_api_secret GET $schema_registry_url/subjects"
# echo $sr_connection_string

# Put the subjects into an array by curling request
output_subjects=()
subjects_array=$(eval $sr_connection_string | jq -r '.[]')

echo "Writing subjects to subjects_output.txt"
for subject in $subjects_array; do
 #sub_output=$(echo $subject | sed --regexp-extended 's/(-value|-key)$//')
 $(printf "%s\n" "$subject" >> subjects_output.txt)
done

#Connect and get topics from cluster
echo "Connecting to Confluent Cluster to get Topics ${rest_url}/kafka/v3/clusters/${rest_cluster_id}/topics"
url_creds=$(echo -n "$rest_api_key:$rest_api_secret" |base64 -w 0)
ru_connection_string="curl -s -X GET -H \"Content-Type: application/json\" -H \"Authorization: Basic ${url_creds}\" ${rest_url}/kafka/v3/clusters/${rest_cluster_id}/topics"

#flatten topic json to just a list of topic names
topics_output=$(eval $ru_connection_string |jq -r '.data | .[].topic_name')
readarray -t topics_array <<< "$topics_output"

#Write Topic array out to file
echo "Writing Topics to topics_output.txt"
for topic in $topics_array; do
 $(printf "%s\n" "$topic" >> topics_output.txt)
done

containsElement "supplier_topic" "${topics_array[@]}" && echo "yes"  || echo "no"
# Compare array values in subject list with topic list
for subject in $subjects_array;do 
  topic_name=$(echo $subject | sed --regexp-extended 's/(-value|-key|\s)$//')
  found=no
  containsElement "${topic_name}" "${topics_array[@]}" && found="yes" || found="no"
   if [[ "${found}" == "yes" ]] 
   then echo "$subject|$topic_name|+"
   else echo "$subject|$topic_name|-"
   fi
done
