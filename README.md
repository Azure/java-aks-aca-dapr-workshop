# Java Dapr-AKS-ACA Workshop

[![Open in GitHub Codespaces](https://img.shields.io/badge/Github_Codespaces-Open-black?style=for-the-badge&logo=github
)](https://codespaces.new/Azure/java-aks-aca-dapr-workshop)
[![Open in Remote - Dev Containers](https://img.shields.io/badge/Dev_Containers-Open-blue?style=for-the-badge&logo=visualstudiocode
)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/Azure/java-aks-aca-dapr-workshop)

## Introduction

This workshop teaches you how to apply [Dapr](https://dapr.io) to a Java microservices application and enable developers to move between multiple pub-sub, state stores and secret store components seamlessly. It also demonstrates Dapr's builtin support for [distributed tracing](https://docs.dapr.io/concepts/observability-concept/) using any backend monitoring tools. Finally, the workshop provides hands on experience in deploying the microservices in both [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/) and [Azure Contaner Apps](https://learn.microsoft.com/en-us/azure/container-apps/overview)

### The domain

For the assignments you will be working with a speeding-camera setup as can be found on several Dutch highways. This is an overview of the fictitious setup you're simulating:

![Speeding cameras](img/speed-trap-overview.png)

There's 1 entry-camera and 1 exit-camera per lane. When a car passes an entry-camera, the license-number of the car and the timestamp is registered.

When the car passes an exit-camera, this timestamp is also registered by the system. The system then calculates the average speed of the car based on the entry- and exit-timestamp. If a speeding violation is detected, a message is sent to the Central Fine Collection Agency (or CJIB in Dutch). They will retrieve the information of the owner of the vehicle and send him or her a fine.


## Workshop

The workshop is available [here](https://azure.github.io/java-aks-aca-dapr-workshop/).

