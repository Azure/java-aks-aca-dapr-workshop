---
title: Cleanup
has_children: false
nav_order: 10
layout: default
---

# Cleanup

The cleanup section consists in deleting the resources created during the workshop. To do so, you just need to delete the resource group containing all the resources:

```bash
az group delete --name rg-dapr-workshop-java --no-wait --yes
```