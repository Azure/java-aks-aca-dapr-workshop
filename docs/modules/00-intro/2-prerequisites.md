---
title: Prerequisites
parent: Basic Concepts and Prerequisites
has_children: false
nav_order: 2
layout: default
---

# Prerequisites

Make sure you have the following prerequisites installed on your machine:

- Git ([download](https://git-scm.com/))
- A code editor or IDE like:
  - Visual Studio Code ([download](https://code.visualstudio.com/))
  - IntelliJ IDEA ([download](https://www.jetbrains.com/idea/download/))
  - Eclipse IDE for Java Developers ([download])(https://www.eclipse.org/downloads/))
- Docker for desktop ([download](https://www.docker.com/products/docker-desktop)) or Rancher Desktop ([download](https://rancherdesktop.io/))
- [Install the Dapr CLI](https://docs.dapr.io/getting-started/install-dapr-cli/) and [initialize Dapr locally](https://docs.dapr.io/getting-started/install-dapr-selfhost/)
- Java 16 or above ([download](https://adoptopenjdk.net/?variant=openjdk16))
- Apache Maven 3.6.3 or above is required; Apache Maven 3.8.1 is advised ([download](http://maven.apache.org/download.cgi))
  - Make sure that Maven uses the correct Java runtime by running `mvn -version`.
- Clone the source code repository:

```bash
git clone https://github.com/Azure/dapr-java-workshop.git
```

**From now on, this folder is referred to as the 'source code' folder.**

{: .important-title }
> Powershell
>
> If you are using Powershell, you need to replace in multiline commands `\` by **`** at then end of each line.
> 