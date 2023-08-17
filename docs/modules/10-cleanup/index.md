---
title: Cleanup
has_children: false
nav_order: 10
layout: default
---

# Cleanup

The cleanup section consists in deleting the resources created during the workshop. If you followed the assignment on secret store or the assignment on managed identities, please follow the complete instructions below. If not, you can just delete the resource group:

```bash
az group delete --name rg-dapr-workshop-java --no-wait --yes
```

{: .important }
> Role assignement, Azure AD application and its service principal are not deleted when deleting the resource group. You need to delete them manually. Therefore follow the instruction below if you setup the secret store and/or the managed identities.

// TODO add the remark in bonus assignment and aca challenge cleanup

## Secret Store cleanup

The application in Azure AD, its service principal and the role assigned to the service principal are not delete when the resource group is deleted. Therefore, before deleting the resource group, you need to delete the role assignment, the service principal and the application. Follow these instructions only if you have done the bonus assignment on secret store or the assignment 7 of the container apps challenge.

{: .note }
> This is already done if you followed the `Step 2` of bonus assignment on managed identities or if you have completed the assignment 8 of the container apps challenge.
>

1. Remove the role assignment for the service principal:

    ```bash
    az role assignment delete \
      --assignee "$SERVICE_PRINCIPAL_ID" \
      --role "Key Vault Secrets User" \
      --scope "$KEY_VAULT_ID"
    ```

    The [role assignment is not deleted when a service principal is deleted](https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep#symptom---role-assignments-with-identity-not-found). So you need to delete it explicitely.

1. Delete the service principal:

    ```bash
    az ad sp delete \
      --id "$SERVICE_PRINCIPAL_ID"
    ```

1. Delete that application in Azure AD:

    ```bash
    az ad app delete \
      --id "$APP_ID"
    ```


## Managed Identities cleanup

The role assignments are not deleted when managed identities are delete. Therefore, before deleting the managed identities in the resource group, you need to delete the role assignment. You need also to delete the role assignment for the SMI of the container apps. Follow these instructions only if you have done the bonus assignment on managed identities or the assignment 8 of the container apps challenge.

1. Delete role assignment for the container registry:

    ```bash
    az role assignment delete \
      --assignee "$ACR_PULL_UMI_PRINCIPAL_ID" \
      --role "AcrPull" \
      --scope "$CONTAINER_REGISTRY_ID"
    ```

1. Delete role assignment for the key vault:

    ```bash
    az role assignment create \
      --assignee "$FINE_COLLECTION_SERVICE_SMI_PRINCIPAL_ID" \
      --role "Key Vault Secrets User" \
      --scope "$KEY_VAULT_ID"
    ```

1. Delete role assignment for the service bus:

    ```bash
    az role assignment create \
      --assignee "$SERVICE_BUS_UMI_PRINCIPAL_ID" \
      --role "Azure Service Bus Data Owner" \
      --scope "$SERVICE_BUS_ID"
    ```

## Delete all other resources

To delete all other resources, you can delete the resource group:

```bash
az group delete --name rg-dapr-workshop-java --no-wait --yes
```