# Dapr Workshop for Pub/Sub and Observability in Java 

## Introduction

This workshop teaches you how to apply [Dapr](https://dapr.io) to a Java microservices application using Pub/Sub with Kafka.

### The domain

For the assignments you will be working with a speeding-camera setup as can be found on several Dutch highways. This is an overview of the fictitious setup you're simulating:

![Speeding cameras](img/speed-trap-overview.png)

There's 1 entry-camera and 1 exit-camera per lane. When a car passes an entry-camera, the license-number of the car and the timestamp is registered.

When the car passes an exit-camera, this timestamp is also registered by the system. The system then calculates the average speed of the car based on the entry- and exit-timestamp. If a speeding violation is detected, a message is sent to the Central Fine Collection Agency (or CJIB in Dutch). They will retrieve the information of the owner of the vehicle and send him or her a fine.

## Assignment 8 - Using Redis to store the state of the vehicle

### Step 1: Add Redis as state store

1. **Copy or Move** this file `dapr/redis-statestore.yaml` to `dapr/components/` folder.

2. Open the `TrafficControlService` project in your IDE and navigate to the `TrafficControlConfiguration` class.

3. **Update** @Bean method to instantiate `DaprVehicleStateRepository` instead of `InMemoryVehicleStateRepository`

```java
    @Bean
    public VehicleStateRepository vehicleStateRepository(final DaprClient daprClient) {
        return new DaprVehicleStateRepository(daprClient);
    }
```

4. **Uncomment** following @Bean method if not already done
  
```java
//    @Bean
//    public DaprClient daprClient() {
//        return new DaprClientBuilder()
//                .withObjectSerializer(new JsonObjectSerializer())
//                .build();
//    }
```

5. Check all your code-changes are correct by building the code. Execute the following command in the terminal window:

   ```console
   mvn package
   ```

Now you can test the application

### Step 2: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```console
   dapr run --app-id vehicleregistrationservice --app-port 6002 --dapr-http-port 3602 --dapr-grpc-port 60002 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `FineCollectionService`.

1. Enter the following command to run the FineCollectionService with a Dapr sidecar:

   ```console
   dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `TrafficControlService`.

1. Enter the following command to run the TrafficControlService with a Dapr sidecar:

   ```console
   dapr run --app-id trafficcontrolservice --app-port 6000 --dapr-http-port 3600 --dapr-grpc-port 60000 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a **new** terminal window and change the current folder to `Simulation`.

1. Start the simulation:

   ```console
   mvn spring-boot:run
   ```

You should see the same logs as before. Obviously, the behavior of the application is exactly the same as before.

### Step 3: Deploy Redis state store to AKS

1. Deploy Redis to kubernetes using helm chart

```bash
helm repo add azure-marketplace https://marketplace.azurecr.io/helm/v1/repo
helm install redis azure-marketplace/redis
```

2. **Copy** this file `dapr/redis-statestore.yaml` to `deploy/` folder.

3. **Update** the `deploy/redis-statestore.yaml` file to use the Redis instance deployed in the previous step

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
spec:
  type: state.redis
  version: v1
  metadata:
  - name: redisHost
    value: redis-master.default.svc.cluster.local:6379
  - name: redisPassword
    secretKeyRef:
      name: redis
      key: redis-password
  - name: actorStateStore
    value: "true"
scopes:
  - trafficcontrolservice
```

The `redisHost` is set to the host name of the Redis instance deployed in the previous step: `redis-master.default.svc.cluster.local:6379`. The master is used because replicas are read-only. The value is given when the helm chart is installed.

The `redisPassword` is set to the password of the Redis instance deployed in the previous step. The password is stored in a secret named `redis` and the key is `redis-password`. This secret is created when the helm chart is installed. To check that the secret exists, run the following command:

```bash
kubectl describe secret redis
```

> *NOTE*
>
> Never integrate secret in a kubernetes manifest directly, use kubernetes secret instead.
>

4. Delete the image from local docker and from the Azure Container Registry

```console
docker rmi traffic-control-service:1.0-SNAPSHOT
az acr repository delete -n daprworkshopjava --image traffic-control-service:latest
```

5. In the root folder/directory of the TrafficControlService microservice, run the following command

```bash
mvn spring-boot:build-image
docker tag traffic-control-service:1.0-SNAPSHOT daprworkshopjava.azurecr.io/traffic-control-service:latest
docker push daprworkshopjava.azurecr.io/traffic-control-service:latest
```

4. From the root folder/directory of the repo, run the following command

```bash
kubectl apply -k deploy
```

### Step 4. Test the applications running in AKS

1. run the following command to identify the name of each microservice pod

```bash
kubectl get pods
```

2. look at the log file of each application pod to see the same output as seen when running on your laptop. For example,

```bash
kubectl logs finecollectionservice-ccf8c9cf5-vr8hr -c fine-collection-service
```

3. delete all application deployments

```azurecli
kubectl delete -k deploy
```
