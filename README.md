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

 ### To get a list of all connectors in a pretty tabular format
 ```
 curl -s -S 'https://api.hub.confluent.io/api/plugins?per_page=100000' | jq -r 'sort_by([].name)|["name","version","release_date"] , (.[]|[.name,.version,.release_date]) |@csv'|tr -d '"' | column -t -s "," 
 ```
 #### Output looks like the following:
 ```
 name                                         version            release_date
baffle-transforms                            1.0.7              2023-03-10
clickhouse-kafka-connect                     0.0.17             2023-07-13
cockroach-cdc                                19.1.0
confluent-sap-connector                      9.3
connect                                      5.7.01
connect-transforms                           1.4.3              2022-06-09
data-replication                             11.4.0
databricks-kafka                             6.4
...
 ```