---
title: Assignment 5 - Deploying Applications to AKS with Dapr Extension
has_children: false
nav_order: 7
---

# Assignment 5A - Deploying Applications to AKS with Dapr Extension

## Setup

1. Install [Helm](https://helm.sh/docs/intro/install/)
2. login to azure

```azurecli
az login
```

3. Create an Azure Container Registry (ACR) resource

  - create Resource Group
  
```bash
az group create --name dapr-workshop-java --location eastus
```

  - set Resource Group as default

```bash
az configure --defaults group=dapr-workshop-java
```

  - create acr

```bash
az acr create --name daprworkshopjava --sku Basic
```

4. Create an AKS cluster with the ACR attached

```bash
az aks create \
    --name dapr-workshop-java-aks \
    --generate-ssh-keys \
    --attach-acr daprworkshopjava \
    --enable-managed-identity
```

5. Update AKS with Dapr extension

```azurecli
az k8s-extension create --cluster-type managedClusters \
--cluster-name dapr-workshop-java-aks \
--name myDaprExtension \
--extension-type Microsoft.Dapr 
```

6. Download AKS cluster kubecofig file, and install kubectl CLI

```bash
az aks install-cli
az aks get-credentials -n dapr-workshop-java-aks -g <NAME-OF-RESOURCE-GROUP>
```

## Step 1 - Deploy kafka to AKS, and configure Dapr

1. Deploy kafka to kubernetes using helm chart

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/kafka
```

2. Configure Dapr to use kafka for pubsub

```bash
cd deploy
kubectl apply -f kafka-pubsub.yaml
```

## Step 2 - Generate Docker images for applications, and push them to ACR

1. login to your ACR repository

```azurecli
az acr login --name daprworkshopjava
```

2. In the root folder/directory of each of the TravelRegistrationService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag vehicle-registration-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/vehicle-registration-service:latest
docker push daprworkshopjava.azurecr.io/vehicle-registration-service:latest
```

3. In the root folder/directory of each of the FineCollectionService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag fine-collection-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/fine-collection-service:latest
docker push daprworkshopjava.azurecr.io/fine-collection-service:latest
```
4. In the root folder/directory of each of the TrafficControlService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag traffic-control-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/traffic-control-service:latest
docker push daprworkshopjava.azurecr.io/traffic-control-service:latest
```

5. In the root folder/directory of each of the SimulationService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag simulation:1.0-SNAPSHOT daprworkshopjava.azurecr.io/simulation:latest
docker push daprworkshopjava.azurecr.io/simulation:latest
```

## Step 3 - Deploy Kubernetes manifest files for applications to AKS

1. From the root folder/directory of the repo, run the following command

```bash
kubectl apply -k deploy
```

## Step 4 - Test the applications running in AKS

1. run the following command to identify the name of each microservice pod

```bash
kubectl get pods
```

2. look at the log file of each application pod to see the same output as seen when running on your laptop. For example,

```bash
kubectl logs trafficcontrolservice-7d8f48b778-rx8l8 -c traffic-control-service
```

3. delete all application deployments

```azurecli
kubectl delete -k deploy
```

# Assignment 5B - Observability with Dapr using OpenTelemetry

In this section, you will deploy the [OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector) to our new AKS cluster and configure Dapr to send telemetry to the vendor agnostic collector implementation. The collector will be configured to send telemetry to an Application Insights resource that we will create within our existing Azure resource group.

## Step 1: Create Application Insights resource

Run the following Azure CLI command to create the Application Insights resource in Azure.

```azure cli
az monitor app-insights component create --app dapr-workshop-java-aks --location eastus --kind web -g dapr-workshop-java --application-type web
```

> You may receive a message to install the application-insights extension, if so please install the extension for this exercise.

After the command completes, the output from the command will contain a property called "instrumentationKey" that will contain a unique identifier you will need to copy and save for later.

## Step 2: Configure OpenTelemetry Collector

Create a new file called `open-telemetry-collector-appinsights.yaml` at the root of the solution and copy the following contents into the file and save.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-conf
  labels:
    app: opentelemetry
    component: otel-collector-conf
data:
  otel-collector-config: |
    receivers:
      zipkin:
        endpoint: 0.0.0.0:9411
    extensions:
      health_check:
      pprof:
        endpoint: :1888
      zpages:
        endpoint: :55679
    exporters:
      logging:
        loglevel: debug
      azuremonitor:
        endpoint: "https://dc.services.visualstudio.com/v2/track"
        instrumentation_key: "<INSTRUMENTATION-KEY>"
        # maxbatchsize is the maximum number of items that can be
        # queued before calling to the configured endpoint
        maxbatchsize: 100
        # maxbatchinterval is the maximum time to wait before calling
        # the configured endpoint.
        maxbatchinterval: 10s
    service:
      extensions: [pprof, zpages, health_check]
      pipelines:
        traces:
          receivers: [zipkin]
          exporters: [azuremonitor,logging]
---
apiVersion: v1
kind: Service
metadata:
  name: otel-collector
  labels:
    app: opencesus
    component: otel-collector
spec:
  ports:
  - name: zipkin # Default endpoint for Zipkin receiver.
    port: 9411
    protocol: TCP
    targetPort: 9411
  selector:
    component: otel-collector
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-collector
  labels:
    app: opentelemetry
    component: otel-collector
spec:
  replicas: 1  # scale out based on your usage
  selector:
    matchLabels:
      app: opentelemetry
  template:
    metadata:
      labels:
        app: opentelemetry
        component: otel-collector
    spec:
      containers:
      - name: otel-collector
        image: otel/opentelemetry-collector-contrib:0.50.0
        command:
          - "/otelcol-contrib"
          - "--config=/conf/otel-collector-config.yaml"
        resources:
          limits:
            cpu: 1
            memory: 2Gi
          requests:
            cpu: 200m
            memory: 400Mi
        ports:
          - containerPort: 9411 # Default endpoint for Zipkin receiver.
        volumeMounts:
          - name: otel-collector-config-vol
            mountPath: /conf
        livenessProbe:
          httpGet:
            path: /
            port: 13133
        readinessProbe:
          httpGet:
            path: /
            port: 13133
      volumes:
        - configMap:
            name: otel-collector-conf
            items:
              - key: otel-collector-config
                path: otel-collector-config.yaml
          name: otel-collector-config-vol
```

Next, find the Instrumentation Key value you copied from the previous step and replace the `<INSTRUMENTATION-KEY>` placeholder with this value and save.

Apply this configuration to your AKS cluster using the following command

```console
kubectl apply -f open-telemetry-collector-appinsights.yaml
```

## Step 3: Configure Dapr to send tracing to OpenTelemetry Collector

Next, we need to configure Dapr to send tracing information to our newly deployed OpenTelemetry Collector using the following configuration file.

Create a new file called `collector-config.yaml` at the root of the solution and copy the text below into it and save.

```yaml
apiVersion: dapr.io/v1alpha1
kind: Configuration
metadata:
  name: appconfig
  namespace: default
spec:
  tracing:
    samplingRate: "1"
    zipkin:
      endpointAddress: "http://otel-collector.default.svc.cluster.local:9411/api/v2/spans"

```

Apply this configuration to your AKS cluster using the following command

```console
kubectl apply -f collector-config.yaml
```

## Step 4: Configure Java Deployments to use Dapr

The Java deployments that are currently running in AKS need to be configured to use the new `appConfig` configuration that was just applied.

Add the following annotations to each of the java deployments that will be participating sending tracing telemetry to the OpenTelemetry Collector endpoint.

### TrafficControlService

Find the `trafficcontrolservice-deployment.yaml file created in the previous assignment and make sure the annotations look like below.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    metadata:
      ...
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "trafficcontrolservice"
        dapr.io/app-port: "6000"
        dapr.io/config: "appconfig"
```

### FineCollectionService

Find the `finecollectionservice-deployment.yaml file created in the previous assignment and make sure the annotations look like below.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  ...
spec:
  ...
  template:
    metadata:
      ...
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "finecollectionservice"
        dapr.io/app-port: "6001"
        dapr.io/config: "appconfig"
```

Apply these two configurations to AKS using the following two commands.

```console
kubectl apply -f deploy/trafficcontrolservice-deployment.yaml
```

```console
kubectl apply -f deploy/finecollectionservice-deployment.yaml
```

## Step 5: Verify telemetry in Application Insights

Open the Azure Portal and navigate to the Application Insights resource within your resource group.

Open the Application Insights blade and click on the `Search` button in the navigation and run query.

If configured correctly, tracing data should show up in the search results.

Find the Application Map feature within the lefthand navigation of the Application Insights blade and click to show the mapping of telemetry calls between services.
