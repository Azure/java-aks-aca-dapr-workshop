---
title: Prerequisites
parent: Basic Concepts and Prerequisites
has_children: false
nav_order: 1
---

# Assignment 0 - Prerequisites

Make sure you have the following prerequisites installed on your machine:

- Git ([download](https://git-scm.com/))
- Eclipse IDE for Java Developers ([download](https://www.eclipse.org/downloads/)
- Docker for desktop ([download](https://www.docker.com/products/docker-desktop)) or Rancher Desktop ([Download](https://rancherdesktop.io/))
- [Install the Dapr CLI](https://docs.dapr.io/getting-started/install-dapr-cli/) and [initialize Dapr locally](https://docs.dapr.io/getting-started/install-dapr-selfhost/)
- Java 16 or above ([download](https://adoptopenjdk.net/?variant=openjdk16))
- Apache Maven 3.6.3 or above is required; Apache Maven 3.8.1 is advised ([download](http://maven.apache.org/download.cgi))
  - Make sure that Maven uses the correct Java runtime by running `mvn -version`.
- Apache Kafka - either run as a docker container (see below) or install and run on your machine ([download](https://kafka.apache.org/downloads))

## Running Kafka using Docker Desktop

From the root of this repository, run the following command to configure and start Kafka from your locally installed Docker Desktop

```console
docker-compose up -d
```

This command will read the docker-compose.yml file located within the root folder and download and run Kafka containers for this workshop.

## Prevent port collisions

During the workshop you will run the services in the solution on your local machine. To prevent port-collisions, all services listen on a different HTTP port. When running the services with Dapr, you need additional ports for HTTP and gRPC communication with the sidecars. By default these ports are `3500` and `50001`. But to prevent confusion, you'll use totally different port numbers in the assignments. If you follow the instructions, the services will use the following ports for their Dapr sidecars to prevent port collisions:

| Service                    | Application Port | Dapr sidecar HTTP port | Dapr sidecar gRPC port |
|----------------------------|------------------|------------------------|------------------------|
| TrafficControlService      | 6000             | 3600                   | 60000                  |
| FineCollectionService      | 6001             | 3601                   | 60001                  |
| VehicleRegistrationService | 6002             | 3602                   | 60002                  |

If you're doing the DIY approach, make sure you use the ports specified in the table above.

The ports can be specified on the command-line when starting a service with the Dapr CLI. The following command-line flags can be used:

- `--app-port`
- `--dapr-http-port`
- `--dapr-grpc-port`

If you're on Windows with Hyper-V enabled, you might run into an issue that you're not able to use one (or more) of these ports. This could have something to do with aggressive port reservations by Hyper-V. You can check whether or not this is the case by executing this command:

```powershell
netsh int ipv4 show excludedportrange protocol=tcp
```

If you see one (or more) of the ports shown as reserved in the output, fix it by executing the following commands in an administrative terminal:

```powershell
dism.exe /Online /Disable-Feature:Microsoft-Hyper-V
netsh int ipv4 add excludedportrange protocol=tcp startport=6000 numberofports=3
netsh int ipv4 add excludedportrange protocol=tcp startport=3600 numberofports=3
netsh int ipv4 add excludedportrange protocol=tcp startport=60000 numberofports=3
dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All
```

Follow the instructions below to get started:

1. Clone the source code repository:

```bash
git clone https://github.com/azure/dapr-java-pubsub.git
```

   **From now on, this folder is referred to as the 'source code' folder.**