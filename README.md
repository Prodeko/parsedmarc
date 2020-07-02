# :e-mail: parsedmarc

This repo is based of off https://github.com/dragoangel/parsedmarc-dockerized. It is modified to support running the project on Azure Container Instances (ACI).

## :information_source: Info

This stack includes:

- [ParseDMARC](https://domainaware.github.io/parsedmarc/)
- [Elasticsearch & Kibana](https://www.elastic.co/guide/index.html) to store and visualize parsed data

## :gear: How-to deploy from scratch

1. Install [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/).
2. Allow IMAP access to reports@prodeko.org in gmail settings. Also allow less secure apps access from the accounts settings.
3. Set reports@prodeko.org password in the [parsedmarc/parsedmarc.ini](./parsedmarc/parsedmarc.ini) file
   Syntax and description avaible [here](https://domainaware.github.io/parsedmarc/index.html#configuration-file)

```
[imap]
host = imap.example.com
user = reports@prodeko.org
password = insertpasswordhere
```

6. Build the containers and push them to Prodeko's Azure Container Registry

- Before pushing you have login to the registry with `az acr login --name prodekoregistry`

```
docker-compose build
docker-compose push
```

7. Run `` from Prodeko's [infrastructure repo](https://github.com/Prodeko/infrastructure).

8. Download & Import [kibana_saved_objects.ndjson](https://raw.githubusercontent.com/domainaware/parsedmarc/master/kibana/export.ndjson).

Go to `https://dmarc.prodeko.org/app/kibana#/management/kibana/objects?_g=()` click on `Import`.

Import downloaded kibana_saved_objects.ndjson with override.

## Elasticsearch issues

If you are not seeing recent updates in the Kibana dasboard try the following useful commands to debug cluster health and shard allocation issues:

```
# Run from kibana container
$ curl -XGET 'http://localhost:9200/_cluster/health?pretty'

# Source: https://www.datadoghq.com/blog/elasticsearch-unassigned-shards/
# Understand shard allocation issues
$ curl -XGET 'http://localhost:9200/_cluster/allocation/explain?pretty'

# Delete all shards
# WARNING: you should restart the container group in order to create the indices again
$ curl -XDELETE http://localhost:9200/_all

# The following command was used to set the 'number_of_replicas' setting on all existing indices to 0
$ curl -XPUT "http://localhost:9200/_template/default_template" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["*"],
  "settings": {
    "number_of_replicas": 0
  }
}
'
```

If nothing else works, deleting all indices from kibana dashboard (or deleting all files inside aci-parsedmarc-elasticsearch-share file share in prodekostorage) and then restarting the container group should help. Remember to import the kibana_saved_objects.ndjson again.

## Dashboard Sample

![ParceDMARC-Sample](./ParceDMARC-Sample.png)
