# Index IAC
Index infrastructure as code repository which contains all ArgoCD configs to get Index backend services up and running on a k8s cluster.  
  
The code for the kubernetes cluster setup can be found [in this repository](https://github.com/Giuliopime/gport).  

#### secrets management
Secrets cannot be commited to git, for this reason we use [sealed secrets](https://github.com/bitnami-labs/sealed-secrets)

1) Install `kubeseal` and `yq` on your local machine:
    ```shell
    brew install kubeseal yq
    ``` 
2) Follow [installation instructions](https://github.com/bitnami-labs/sealed-secrets?tab=readme-ov-file#installation) for sealed-secrets
    ```shell
    kubectl apply -k ./sealed-secrets-installation
    ```
3) Prepare secrets:  
   In each folder under `/k8s-resources` there can be a `/secrets` folder.  
   Each contains a `*-secret.template.yaml` file, duplicate it and remove the `.template` part from the new file name. Then fill out the values.
4) Seal the secrets:
    ```shell
    chmod +x scripts/seal-secrets.sh && scripts/seal-secrets.sh
    ```
   (Recommended) You can also provide a specific folder to the script, instead of sealing all secrets: `scripts/seal-secrets.sh cert-manager`

5) Commit and push the changes
