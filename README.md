# Confluent Scripts

## schema_check.sh 

Script to extract schemas(subjects) and all cluster topics and compares schema against topic using `topicNamingStrategy.
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
