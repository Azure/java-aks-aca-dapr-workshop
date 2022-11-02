---
title: Using Dapr for pub/sub with RabbitMQ
parent: Assignment 3 - Using Dapr for pub/sub with other brokers
has_children: false
nav_order: 1
---

# Using Dapr for pub/sub with RabbitMQ

Stop Simulation, TrafficControlService and FineCollectionService, and VehicleRegistrationService by pressing Crtl-C in the respective terminal windows.

## Step 1: Run RabbitMQ as message broker

In the example, you will use RabbitMQ as the message broker with the Dapr pub/sub building block. You're going to pull a standard Docker image containing RabbitMQ to your machine and start it as a container.

1. Open a terminal window.

1. Start a RabbitMQ message broker by entering the following command:

   ```console
   docker run -d -p 5672:5672 --name dtc-rabbitmq rabbitmq:3-management-alpine
   ```

This will pull the docker image `rabbitmq:3-management-alpine` from Docker Hub and start it. The name of the container will be `dtc-rabbitmq`. The server will be listening for connections on port `5672` (which is the default port for RabbitMQ).

If everything goes well, you should see some output like this:

```console
❯ docker run -d -p 5672:5672 --name dtc-rabbitmq rabbitmq:3-management-alpine
Unable to find image 'rabbitmq:3-management-alpine' locally
3-management-alpine: Pulling from library/rabbitmq
a0d0a0d46f8b: Pull complete
31312314eeb3: Pull complete
926937e20d4d: Pull complete
f5676ddf0782: Pull complete
ff9526ce7ab4: Pull complete
6163319fe438: Pull complete
592def0a276e: Pull complete
59922d736a7b: Pull complete
76025ca84b3c: Pull complete
4965e42a5d3c: Pull complete
Digest: sha256:8885c08827289c61133d30be68658b67c6244e517931bb7f1b31752a9fcaec73
Status: Downloaded newer image for rabbitmq:3-management-alpine
85a98f00f1a87b856008fec85de98c8412eb099e3a7675b87945c777b131d876
```

> If you see any errors, make sure you have access to the Internet and are able to download images from Docker Hub. See [Docker Hub](https://hub.docker.com/) for more info.

## Step 2: Configure the pub/sub component

1. Open the file `dapr/rabbitmq-pubsub.yaml` in your IDE.

    ```yaml
    apiVersion: dapr.io/v1alpha1
    kind: Component
    metadata:
      name: pubsub
    spec:
      type: pubsub.rabbitmq
      version: v1
      metadata:
      - name: host
        value: "amqp://localhost:5672"
      - name: durable
        value: "false"
      - name: deletedWhenUnused
        value: "false"
      - name: autoAck
        value: "false"
      - name: reconnectWait
        value: "0"
      - name: concurrency
        value: parallel
    scopes:
      - trafficcontrolservice
      - finecollectionservice
    ```

    As you can see, you specify a different type of pub/sub component (`pubsub.rabbit`) and you specify in the `metadata` section how to connect to the rabbitmq server you started in step 1 (running on localhost on port `5672`).
    
    In the `scopes` section, you specify that only the TrafficControlService and FineCollectionService should use the pub/sub building block.

1. **Copy or Move** this file `dapr/rabbit-pubsub.yaml` to `dapr/components/` folder.

1. **Move** the file `dapr/components/kafka-pubsub.yaml` back to `dapr/` folder.

## Step 3: Test the application

You're going to start all the services now. 

1. Make sure no services from previous tests are running (close the command-shell windows).

1. Open the terminal window and make sure the current folder is `VehicleRegistrationService`.

1. Enter the following command to run the VehicleRegistrationService with a Dapr sidecar:

   ```console
   mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `FineCollectionService`.

1. Enter the following command to run the FineCollectionService with a Dapr sidecar:

   ```console
   dapr run --app-id finecollectionservice --app-port 6001 --dapr-http-port 3601 --dapr-grpc-port 60001 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `TrafficControlService`.

1. Enter the following command to run the TrafficControlService with a Dapr sidecar:

   ```console
   dapr run --app-id trafficcontrolservice --app-port 6000 --dapr-http-port 3600 --dapr-grpc-port 60000 --components-path ../dapr/components mvn spring-boot:run
   ```

1. Open a terminal window and change the current folder to `Simulation`.

1. Start the simulation:

   ```console
   mvn spring-boot:run
   ```

You should see the same logs as before. Obviously, the behavior of the application is exactly the same as before. But now, instead of messages being published and subscribed via kafka topic, are being processed through RabbitMQ.