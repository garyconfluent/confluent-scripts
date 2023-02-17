# Confluent Scripts

## schema_check.sh 

Script to extract schemas(subjects) and all cluster topics and compares schema against topic using `topicNamingStrategy`.
### Usage:
```
./schema_check.sh \
    -ru <REST_URL> \
    -rc <CLUSTER_ID> \
    -ra <CLUSTER_API_KEY>  \
    -rs <CLUSTER_API_SECRET> \
    -sr <SCHEMA_REGISTRY_URL> \
    -sa <SCHEMA_REGISTRY_API_KEY> \
    -ss <SCHEMA_REGISTRY_API_SECRET>
```

## connector_plugins.sh

Script to query Confluent Connector Hub to list all connector plugins based on a configuration

### Modify Script Configuration

```
connectors=(

   "kafka-connect-ibmmq"
   "snowflake-kafka-connector"
   "kafka-connect-replicator"
   "kafka-connect-servicenow"
   "kafka-connect-json-schema"
   "kafka-connect-salesforce"
   "kafka-connect-s3-source"

)
```

The Script will output the following:
```
Latest Connector Versions as of 2023-02-17 10:50:43
#####################################################
"kafka-connect-servicenow:2.3.10 - Release Date: 2023-02-14"
"kafka-connect-salesforce:2.0.8 - Release Date: 2023-02-14"
"kafka-connect-s3-source:2.5.1 - Release Date: 2023-02-03"
"kafka-connect-ibmmq:12.1.0 - Release Date: 2023-01-20"
"kafka-connect-replicator:7.3.1 - Release Date: 2022-12-19"
"snowflake-kafka-connector:1.8.2 - Release Date: 2022-11-11"
"kafka-connect-json-schema:0.2.5 - Release Date: 2020-05-19"
 ```