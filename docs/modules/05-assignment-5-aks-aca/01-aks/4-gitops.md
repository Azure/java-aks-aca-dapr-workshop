---
title: (Optional) GitOps
parent: Deploying to Azure Kubernetes Service
grand_parent: Assignment 5 - Deploying to Azure with Dapr
has_children: false
nav_order: 4
layout: default
---

# (Optional) Enable GitOps addon and use it to deploy applications

1. Fork this repository on your personal GitHub account.

2. Create a [personal access token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) that has write permission to repositories (select `repo` under permissions).

3. Export your GitHub access token, username, and your forked repository:

    ```bash
    export GITHUB_TOKEN=<your-token>
    export GITHUB_USER=<your-username>
    export GITHUB_REPO=<your-repo>
    ```

4. Run the following commands:

    ```bash
    az feature register --namespace Microsoft.ContainerService --name AKS-ExtensionManager
    az provider register --namespace Microsoft.Kubernetes
    az provider register --namespace Microsoft.ContainerService
    az provider register --namespace Microsoft.KubernetesConfiguration
    az extension add -n k8s-configuration
    az extension add -n k8s-extension
    ```

5. Enable GitOps extension:

    ```bash
    az k8s-extension create --cluster-type managedClusters \
    --cluster-name aks-dapr-workshop-java \
    --name myGitopsExtension \
    --extension-type Microsoft.Gitops
    ```

6. Apply Flux configuration:

    ```bash
    az k8s-configuration flux create -c aks-dapr-workshop-java -n dapr-workshop-java-flux --namespace cluster-config -t managedClusters --scope cluster -u $GITHUB_REPO --branch main  --kustomization name=test  path=./deploy prune=true --https-user $GITHUB_USER --https-key $GITHUB_TOKEN
    ```

7. verify all application pods are running by executing the following command: `kubectl get pods`.

<!-- ----------------------------- NAVIGATION ------------------------------ -->

<span class="fs-3">
[< (Optional) Observability]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/01-aks/3-observability-with-open-telemetry.md %}){: .btn .mt-7 }
</span>
