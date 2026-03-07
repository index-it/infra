# Secrets
### Docker configs
To allow the k8s cluster to pull images from GCR (Google Container Registry):
- Create a service account in Google Cloud with the following permissions:
  - Artifact Registry Reader
  - Storage Object Viewer
- Download the JSON key file and name it `gcr-pull-key.json`
- Run the following command:
> Make sure your ~/.docker/config.json file doesn't use credsStore (delete the line if present in the file)
```shell
cat gcr-pull-key.json | docker login -u _json_key --password-stdin https://eu.gcr.io
```
```shell
cat ~/.docker/config.json | base64 -w 0 
```
- Insert the output of the above command into the `docker-config-secret.yml` file in the `data..dockerconfigjson` key