# :e-mail: parsedmarc

This repo is based of off https://github.com/dragoangel/parsedmarc-dockerized. It is modified to support running the project on Azure Container Instances (ACI).

## :information_source: Info

This stack includes:

- [ParseDMARC](https://domainaware.github.io/parsedmarc/)
- [Elasticsearch & Kibana](https://www.elastic.co/guide/index.html) to store and visualize parsed data
- [Nginx](https://docs.nginx.com/) to handle basic authorization and SSL

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

4. Acquire certificates and put them into the nginx/ssl folder. The files should be named dmarc.prodeko.org.cer and dmarc.prodeko.org.key.

5. Build the containers and push them to Prodeko's Azure Container Registry

- Before pushing you have login to the registry with `az acr login --name prodekoregistry`

```
docker build parsedmarc/. -t prodekoregistry.azurecr.io/parsedmarc/parsedmarc-main --no-cache
docker build caddy/. -t prodekoregistry.azurecr.io/parsedmarc/parsedmarc-caddy --no-cache
docker build nginx/. -t prodekoregistry.azurecr.io/parsedmarc/parsedmarc-nginx --no-cache
docker build kibana/. -t prodekoregistry.azurecr.io/parsedmarc/parsedmarc-kibana --no-cache
docker build elasticsearch/. -t prodekoregistry.azurecr.io/parsedmarc/parsedmarc-elasticsearch --no-cache

docker push prodekoregistry.azurecr.io/parsedmarc/parsedmarc-main
docker push prodekoregistry.azurecr.io/parsedmarc/parsedmarc-caddy
docker push prodekoregistry.azurecr.io/parsedmarc/parsedmarc-nginx
docker push prodekoregistry.azurecr.io/parsedmarc/parsedmarc-kibana
docker push prodekoregistry.azurecr.io/parsedmarc/parsedmarc-elasticsearch
```

6. Run `terraform apply` from Prodeko's [infrastructure repo](https://github.com/Prodeko/infrastructure).

   - The ACI configuration for parsedmarc is [here](https://github.com/Prodeko/infrastructure/tree/master/modules/containers/parsedmarc)

7. Download & Import [kibana_saved_objects.json](https://raw.githubusercontent.com/domainaware/parsedmarc/master/kibana/kibana_saved_objects.json).

Go to `https://dmarc.prodeko.org/app/kibana#/management/kibana/objects?_g=()` click on `Import`.

Import downloaded kibana_saved_objects.json with override.

## Notes

In the future NGINX could be replaced with caddy for automating certificates. Now the certificates need to be acquired manually.

## Dashboard Sample

![ParceDMARC-Sample](./ParceDMARC-Sample.png)
