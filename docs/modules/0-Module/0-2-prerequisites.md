---
title: Assignment 0 - Prerequisites
parent: Assignment 0 - Basic Concepts and Prerequisites
has_children: false
nav_order: 2
---

# Assignment 0 - Prerequisites

Make sure you have the following prerequisites installed on your machine:

- Git ([download](https://git-scm.com/))
- Eclipse IDE for Java Developers ([download])(https://www.eclipse.org/downloads/))
- Docker for desktop ([download](https://www.docker.com/products/docker-desktop)) or Rancher Desktop ([download](https://rancherdesktop.io/))
- [Install the Dapr CLI](https://docs.dapr.io/getting-started/install-dapr-cli/) and [initialize Dapr locally](https://docs.dapr.io/getting-started/install-dapr-selfhost/)
- Java 16 or above ([download](https://adoptopenjdk.net/?variant=openjdk16))
- Apache Maven 3.6.3 or above is required; Apache Maven 3.8.1 is advised ([download](http://maven.apache.org/download.cgi))
  - Make sure that Maven uses the correct Java runtime by running `mvn -version`.
- Apache Kafka - either run as a docker container (see below) or install and run on your machine ([download](https://kafka.apache.org/downloads))

## Running Kafka as a container

From the root of this repository, run the following command to configure and start Kafka from your locally installed Docker Desktop

```console
docker-compose up -d
```

This command will read the docker-compose.yml file located within the root folder and download and run Kafka containers for this workshop.

Follow the instructions below to get started:

1. Clone the source code repository:

```bash
git clone https://github.com/azure/dapr-java-pubsub.git
```

   **From now on, this folder is referred to as the 'source code' folder.**
