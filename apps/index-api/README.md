# Secrets
### Docker configs
To allow the k8s cluster to pull images from GCR (Google Container Registry):
- Create a service account in Google Cloud with the following permissions:
  - Artifact Registry Reader
  - Storage Object Viewer
- Download the JSON key file and name it `key.json` or whatever you want
- Run the following command:
> Make sure your ~/.docker/config.json file doesn't use credsStore (delete the line if present in the file)
```shell
cat key.json | docker login -u _json_key --password-stdin https://eu.gcr.io
```
```shell
cat ~/.docker/config.json | base64 -w 0 
```
- Insert the output of the above command into the `docker-config-secret.yml` file in the `data..dockerconfigjson` key

### GCP service account for index-api
- Create a service account in GCP with the following permissions:
  - BigQuery Data Editor
  - Cloud Scheduler Admin
  - Cloud Scheduler Service Agent
  - Cloud Tasks Admin (Beta)
  - Cloud Tasks Enqueuer (Beta)
  - Cloud Tasks Task Deleter (Beta)
  - Firebase Cloud Messaging Admin
  - Firebase Cloud Messaging API Admin
  - Service Account Token Creator
  - Service Account User
- Download the JSON key file and name it `key.json` or whatever you want
- Run the following cmd:
```shell
cat key.json | base64 -w 0
```
- Insert the output of the above command into the `gcp-service-account-secret.yml` file in the `data.key.json` key

### ConfigMap with env variables
Currently, env variables are handled manually, run the following to add the to the cluster:
```shell
kubectl create configmap config --from-env-file=.env -n index-api-prod
```