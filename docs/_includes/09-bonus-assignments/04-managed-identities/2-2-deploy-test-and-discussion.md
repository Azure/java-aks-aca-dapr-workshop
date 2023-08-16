## Step 1 - Use a UMI to access Azure Container Registry

Until now, the images were pulled anonymously from the Azure Container Registry (ACR). In this step, you will assing a UMI to each container app that has the role `AcrPull` on the ACR. For this step you will need to:

- Disable the anonymous pull access and the admin user access to the ACR
- Create a UMI and assign it the role `AcrPull` on the ACR to be able to pull images from the ACR
- Assign the UMI to each container app

### Disable anonymous pull and admin accesses to the ACR

To disable anonymous pull access and admin user access to the container registry, enter the following command:

```bash
az acr update \
  --name "$CONTAINER_REGISTRY" \
  --resource-group rg-dapr-workshop-java \
  --anonymous-pull-enabled false \
  --admin-enabled false
```

### Create UMI with `acrPull` role

1. Create a UMI:

    ```bash
    az identity create \
      --name "id-acr-pull" \
      --resource-group rg-dapr-workshop-java
    ```

1. Get the principal id of the managed identity:

    - Linux/Unix shell:

        ```bash
        ACR_PULL_UMI_PRINCIPAL_ID=$(az identity show --name "id-acr-pull" --resource-group rg-dapr-workshop-java --query principalId -o tsv)
        ```

    - Powershell:

        ```powershell
        $ACR_PULL_UMI_PRINCIPAL_ID = az identity show --name "id-acr-pull" --resource-group rg-dapr-workshop-java --query principalId -o tsv
        ```

1. Get the resource id of the container registry:

    - Linux/Unix shell:

        ```bash
        CONTAINER_REGISTRY_ID=$(az acr show --name "$CONTAINER_REGISTRY" --resource-group rg-dapr-workshop-java --query id -o tsv)
        ```

    - Powershell:

        ```powershell
        $CONTAINER_REGISTRY_ID = az acr show --name "$CONTAINER_REGISTRY" --resource-group rg-dapr-workshop-java --query id -o tsv
        ```

1. Assign the role `AcrPull` to the UMI on the container registry:

    ```bash
    az role assignment create \
      --assignee "$ACR_PULL_UMI_PRINCIPAL_ID" \
      --role "AcrPull" \
      --scope "$CONTAINER_REGISTRY_ID"
    ```

You can check that the role has been assigned to the UMI `id-acr-pull` with the following command:

```bash
az role assignment list \
  --assignee "$ACR_PULL_UMI_PRINCIPAL_ID" \
  --scope "$CONTAINER_REGISTRY_ID"
```

Or in the [Azure Portal](https://portal.azure.com):

1. Go to the Azure Container Registry
2. Click on `Access control (IAM)`
3. Click on `Role assignments`
4. Check that `id-acr-pull` is assigned the role `AcrPull`

### Assign UMI to container apps

To provide the permission to pull images from the ACR to the container apps, you need to assign the UMI `id-acr-pull` to each container app and to setup their registry so they know which identity to use to pull images from which container registry.

1. Get the resource id of the managed identity that you created in the previous step:

    - Linux/Unix shell:

        ```bash
        ACR_PULL_UMI_ID=$(az identity show --name "id-acr-pull" --resource-group rg-dapr-workshop-java --query id -o tsv)
        ```

    - Powershell:

        ```powershell
        $ACR_PULL_UMI_ID = az identity show --name "id-acr-pull" --resource-group rg-dapr-workshop-java --query id -o tsv
        ```

#### Vehicle registration service

1. Set the registry:

    ```bash
    az containerapp registry set \
      --name ca-vehicle-registration-service \
      --resource-group rg-dapr-workshop-java \
      --server "$CONTAINER_REGISTRY_URL" \
      --identity "$ACR_PULL_UMI_ID"
    ```

    If you want to use SMI instead of UMI, you need to set `system` for the [`--identity` parameter](https://learn.microsoft.com/en-us/cli/azure/containerapp/registry?view=azure-cli-latest#az-containerapp-registry-set-optional-parameters).

1. Assign the UMI:

    ```bash
    az containerapp identity assign \
      --name ca-vehicle-registration-service \
      --resource-group rg-dapr-workshop-java \
      --user-assigned "$ACR_PULL_UMI_ID"
    ```

    You could have assigned it with the UMI name as the UMI is in the same resource group as the container app.

#### Fine collection service

1. Set the registry:

    ```bash
    az containerapp registry set \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --server "$CONTAINER_REGISTRY_URL" \
      --identity "$ACR_PULL_UMI_ID"
    ```

1. Assign the UMI:

    ```bash
    az containerapp identity assign \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --user-assigned "id-acr-pull"
    ```

#### Traffic control service

1. Set the registry:

    ```bash
    az containerapp registry set \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --server "$CONTAINER_REGISTRY_URL" \
      --identity "$ACR_PULL_UMI_ID"
    ```

1. Assign the UMI:

    ```bash
    az containerapp identity assign \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --user-assigned ""$ACR_PULL_UMI_ID""
    ```

{: .note }
> If at this stage, you want to test the application, please follow steps 6 to 8.
> 

## Step 2 - Access Key Vault with SMI

Until now, the container apps have used the client secret of the Key Vault service principal to access Key Vault. In this step, you will use a SMI to access Key Vault for both fine collection service and traffic control service. 

For this step you will need to:
- Assign a SMI to both fine collection service and traffic control
- Assign the role `Key Vault Secrets User` to both SMI
- Update `secretstore` Dapr component to remove the client id and client secret of the Key Vault service principal
- Remove the service principal used for the Key Vault

{: .note }
> Traffic control service does not need to acces the Key Vault at the end of this assignment as it will use the managed identity of the container app to access the Cosmos DB and the service bus. It stil shows how you can reference secrets in Dapr component using the secret store and managed identities to access the key vault. This is how you can securely access non-Azure services.
>

### Assign SMI to container apps

1. Assign SMI to fine collection service:

    ```bash
    az containerapp identity assign \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --system-assigned
    ```

1. Assign SMI to traffic control service:

    ```bash
    az containerapp identity assign \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --system-assigned
    ```

### Assign role to SMI

You need to assign the role `Key Vault Secrets User` to the SMI of both fine collection service and traffic control service.

#### Fine collection service

1. Get the principal id of fine collection service SMI:

    - Linux/Unix shell:

        ```bash
        FINE_COLLECTION_SERVICE_SMI_PRINCIPAL_ID=$(az containerapp identity show --name ca-fine-collection-service --resource-group rg-dapr-workshop-java --query principalId -o tsv)
        ```

    - Powershell:

        ```powershell
        $FINE_COLLECTION_SERVICE_SMI_PRINCIPAL_ID = az containerapp identity show --name ca-fine-collection-service --resource-group rg-dapr-workshop-java --query principalId -o tsv
        ```

1. Get the resource id of the key vault:

    - Linux/Unix shell:

        ```bash
        KEY_VAULT_ID=$(az keyvault show --name "$KEY_VAULT" --query id -o tsv)
        ```

    - Powershell:

        ```powershell
        $KEY_VAULT_ID = az keyvault show --name "$KEY_VAULT" --query id -o tsv
        ```
    
    Note that the resource group is not needed as the Key Vault has a globaly unique name.

1. Assign role `Key Vault Secrets User` to the SMI:

    ```bash
    az role assignment create \
      --assignee "$FINE_COLLECTION_SERVICE_SMI_PRINCIPAL_ID" \
      --role "Key Vault Secrets User" \
      --scope "$KEY_VAULT_ID"
    ```

#### Traffic control service

{: .new-title }
> Challenge
>
> Do the same for traffic control service:
> 
> - Get the principal id of traffic control service SMI and set it to the variable `TRAFFIC_CONTROL_SERVICE_SMI_PRINCIPAL_ID`
> - Assign role `Key Vault Secrets User` to the SMI
>

{: .note }
> Check that both SMI have assigned role before continuing.
>

### Update `secretstore` Dapr component

You need to update the `secretstore` Dapr component to remove the client id and client secret of the Key Vault service principal.

1. Update `dapr/component/aca-azure-keyvault-secretstore.yaml` to have a manifest that looks like this:

    ```yaml
    componentType: secretstores.azure.keyvault
    version: v1
    metadata:
      - name: vaultName
        value: "[your_keyvault_name]"
    scopes:
      - traffic-control-service
      - fine-collection-service
    ```

    Where `[your_keyvault_name]` should be replaced with the name of your key vault. Only the vault name is needed to define the secret store with SMI and Azure Key Vault.

1. Deploy the udpated component manifest:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java \
      --resource-group rg-dapr-workshop-java \
      --dapr-component-name secretstore \
      --yaml ./dapr/components/aca-azure-keyvault-secretstore.yaml
    ```

### Remove Key Vault service principal

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

{: .note }
> If at this stage, you want to test the application, please follow steps 6 to 8.
> 

## Step 3 - Use SMI to access Azure Cosmos DB

Only traffic control service needs to access Azure Cosmos DB. Therefore, you will use the SMI of traffic control service created in the previous step and you will assign it the role [`Cosmos DB Built-in Data Contributor`](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#built-in-role-definitions). After the role is assigned you will udpate the component manifest to remove the Cosmos DB master key.

1. Assign the role `Cosmos DB Built-in Data Contributor` to the SMI of traffic control service:

    ```bash
    az cosmosdb sql role assignment create \
      --account-name "$COSMOS_DB" \
      --resource-group rg-dapr-workshop-java \
      --principal-id "$TRAFFIC_CONTROL_SERVICE_SMI_PRINCIPAL_ID" \
      --role-definition-name "Cosmos DB Built-in Data Contributor" \
      --scope "/dbs/dapr-workshop-java-database/colls/vehicle-state"
    ```

    This assignment is not done using `az role assignment` like previously. It is done using [`az cosmosdb sql role assignment`](https://learn.microsoft.com/en-us/cli/azure/cosmosdb/sql/role/assignment?view=azure-cli-latest#az-cosmosdb-sql-role-assignment-create) because the role is assigned on a Cosmos DB resource with SQL API. The scope is set to give access only to the container `vehicle-state` of the database `dapr-workshop-java-database`. To know more about the scope for Cosmos DB SQL API, you can refer to [this documentation](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#role-definitions).

1. Update `dapr/components/aca-azure-cosmosdb-statestore.yaml` to have a manifest that looks like this:

    ```yaml
    componentType: state.azure.cosmosdb
    version: v1
    metadata:
      - name: url
        value: <YOUR_COSMOSDB_ACCOUNT_URL>
      - name: database
        value: dapr-workshop-java-database
      - name: collection
        value: vehicle-state
      - name: actorStateStore
        value: "true"
    scopes:
      - traffic-control-service
    ```

    Where `<YOUR_COSMOSDB_ACCOUNT_URL>` should be replace with your COSMOS DB account URL.

1. Deploy the updated component manifest:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java \
      --resource-group rg-dapr-workshop-java \
      --dapr-component-name statestore \
      --yaml ./dapr/components/aca-azure-cosmosdb-statestore.yaml
    ```

{: .note }
> If at this stage, you want to test the application, please follow steps 6 to 8.
> 

## Step 4 - Use UMI to access Azure Service Bus

To acccess the service bus, you will use a UMI and assign it the role `Azure Service Bus Data Owner` for fine collection service and traffic control service at the service bus level. After the role is assigned you will udpate the component manifest to remove the connection string of the service bus.

{: .note }
> The role is `Azure Service Bus Data Owner` because fine collection service needs to create its subscrition on the topic `test` if it does not already exists. To refine the fole between the data receiver and the data sender, please read the documentation on [Azure Service Bus SMI vs UMI](#azure-service-bus).

1. Create a UMI:

    ```bash
    az identity create \
      --name "id-service-bus" \
      --resource-group rg-dapr-workshop-java
    ```

1. Get the principal id of the managed identity:

    - Linux/Unix shell:

        ```bash
        SERVICE_BUS_UMI_PRINCIPAL_ID=$(az identity show --name "id-service-bus" --resource-group rg-dapr-workshop-java --query principalId -o tsv)
        ```

    - Powershell:

        ```powershell
        $SERVICE_BUS_UMI_PRINCIPAL_ID = az identity show --name "id-service-bus" --resource-group rg-dapr-workshop-java --query principalId -o tsv
        ```

1. Get the service bus resource id:

    - Linux/Unix shell:

        ```bash
        SERVICE_BUS_ID=$(az servicebus namespace show --name "$SERVICE_BUS" --resource-group rg-dapr-workshop-java --query id -o tsv)
        ```

    - Powershell:

        ```powershell
        $SERVICE_BUS_ID = az servicebus namespace show --name "$SERVICE_BUS" --resource-group rg-dapr-workshop-java --query id -o tsv
        ```

1. Assign the role `Azure Service Bus Data Owner` to the UMI on the service bus:

    ```bash
    az role assignment create \
      --assignee "$SERVICE_BUS_UMI_PRINCIPAL_ID" \
      --role "Azure Service Bus Data Owner" \
      --scope "$SERVICE_BUS_ID"
    ```

1. Assign the UMI to fine collection service:

    ```bash
    az containerapp identity assign \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --user-assigned "id-service-bus"
    ```

1. Assign the UMI to traffic control service:

    ```bash
    az containerapp identity assign \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --user-assigned "id-service-bus"
    ```

1. Get the client ID of the UMI and note it down. You will need it in the next step.

    ```bash
    az identity show \
      --name "id-service-bus" \
      --resource-group rg-dapr-workshop-java \
      --query clientId \
      -o tsv
    ```

1. Update `dapr/components/aca-azure-servicebus-pubsub.yaml` to have a manifest that looks like this:

    ```yaml
    componentType: pubsub.azure.servicebus
    version: v1
    metadata:
      - name: namespaceName
        value: "<service-bus-namespace-name>.servicebus.windows.net"
      - name: azureClientId
        value: "<UMI-client-id>"
    scopes:
      - traffic-control-service
      - fine-collection-service
    ```
    
    Where `<service-bus-namespace-name>` should be replaced with the name of your service bus namespace (i.e. `$SERVICE_BUS`) and `<UMI-client-id>` should be replaced with the client ID of the UMI that you noted down in the previous step. As you are using a UMI, [`azureClientId` is requested in the component manifest](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml#using-managed-identity).

1. Deploy the updated component manifest:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java \
      --resource-group rg-dapr-workshop-java \
      --dapr-component-name pubsub \
      --yaml ./dapr/components/aca-azure-servicebus-pubsub.yaml
    ```

{: .note }
> If at this stage, you want to test the application, please follow steps 6 to 8.
> 

## Step 5 - Remove traffic control service access to Azure Key Vault

At this stage, traffic control service uses UMI to access the service bus and SMI to access Azure Cosmos DB. It does not used secrets any more, nor in the code, nor in its Dapr components. Therefore there is no need for it to access the Key Vault. We are going to remove its access to the key vault and update the `secretstore` component manifest to allow access to the key vault only for fine collection service.

1. Remove role assignment for traffic control service SMI:

    ```bash
    az role assignment delete \
      --assignee "$TRAFFIC_CONTROL_SERVICE_SMI_PRINCIPAL_ID" \
      --role "Key Vault Secrets User" \
      --scope "$KEY_VAULT_ID"
    ```

1. Update `dapr/components/aca-azure-keyvault-secretstore.yaml` to have a manifest that looks like this:

    ```yaml
    componentType: secretstores.azure.keyvault
    version: v1
    metadata:
      - name: vaultName
        value: "[your_keyvault_name]"
    scopes:
      - fine-collection-service
    ```

    Where `[your_keyvault_name]` should be replaced with the name of your key vault. Only the vault name is needed to define the secret store with SMI and Azure Key Vault.

1. Deploy the udpated component manifest:

    ```bash
    az containerapp env dapr-component set \
      --name cae-dapr-workshop-java \
      --resource-group rg-dapr-workshop-java \
      --dapr-component-name secretstore \
      --yaml ./dapr/components/aca-azure-keyvault-secretstore.yaml
    ```

{: .note }
> If at this stage, you want to test the application, please follow steps 6 to 8.
> 

## Step 6 - Update the application

To be sure that all our changes are working, we are going to update the 3 microservices, i.e. to redeploy them. To do so, without changing the image or the configuration we are just going to update the maximum number of replicas. This is not needed with real workloads, we just do that to ensure changes are taken into account.

1. Update the maximum number of replicas for vehicle registration service:

    ```bash
    az containerapp update \
      --name ca-vehicle-registration-service \
      --resource-group rg-dapr-workshop-java \
      --max-replicas 10
    ```

1. Update the maximum number of replicas for fine collection service:

    ```bash
    az containerapp update \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --max-replicas 10
    ```

1. Update the maximum number of replicas for traffic control service:

    ```bash
    az containerapp update \
      --name ca-traffic-control-service \
      --resource-group rg-dapr-workshop-java \
      --max-replicas 10
    ```

Now you can test the application to ensure that everything is working as before.

<!-- -------------------------------- TEST --------------------------------- -->

{% assign stepNumber = 7 %}
{% include 05-assignment-5-aks-aca/02-aca/0-3-test-application.md %}

## Choosing between SMI and UMI

Choosing between SMI and UMI can be quite challenging. In this assignment, we have done choices to demonstrate the use of both types of managed identities. These choices are not necessarily the best choices for a real world scenario. This is a multiple-criteria decision challenge.

In a real world scenario, you should carefully consider the choice between SMI and UMI. To do so, you can refer to these [good practices](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations#choosing-system-or-user-assigned-managed-identities).

These are some additional considerations that could help you make a choice:

- [Follow the principle of least privilege when granting access to resources](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations#follow-the-principle-of-least-privilege-when-granting-access).
- [When assigning UMI to a container app, all granted permissions of the UMI are then available to the container app](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations#consider-the-effect-of-assigning-managed-identities-to-azure-resources)
- [SMI is created when the container app is created. Role are assigned after the creation. This can cause deployment and/or application failure](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations#choosing-system-or-user-assigned-managed-identities)
- [`azureClientId` is required for any Dapr component authentication using UMI](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml#using-managed-identity)
- [Each subscription is limited to 4000 role assignments](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-portal#list-number-of-role-assignments)

For each ones of these considerations you can find an example related to this workshop in the following sections.

### Principle of least privilege

When granting permissions to access a service to a managed identity, always grant the least permissions needed to perfrom the desired actions. This is the [principle of least privilege](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations#follow-the-principle-of-least-privilege-when-granting-access). This principle is important to follow because it reduces the risk of accidental or intentional misuse of the permissions granted to the managed identity. 

Let's take the example of the application of this workshop to detail this principle. There are 4 services that are accessed by the application:

- Azure Container Registry
- Azure Key Vault
- Azure Cosmos DB
- Azure Service Bus

#### Azure Container Registry

Each container app needs to pull the images from the ACR. It does not need to push images to the ACR. So it needs only the role `AcrPull` on the ACR. It does not need the role `AcrPush`. As every container app requires the same role, a UMI role acrPull should be created and assigned to all container apps.

#### Azure Key Vault

Fine collection service needs to access the license key of fine calculator engine from Azure Key Vault. It does not need to access the other secrets in the Key Vault. So it needs only the role `Key Vault Secrets User` on the Key Vault. It does not need the role `Key Vault Secrets Officer`. In that case, the role `Key Vault Secrets User` should be assigned to the SMI of `ca-fine-collection-service` on key vault secret `license-key` only and not on the key vault itself (like you have done in this assignment).

#### Azure Cosmos DB

Traffic control service needs to managed data only in `vehicle-state` container to keep the state of the vehicles. It does not need to access the other containers nor databases in the Cosmos DB account. It only needs the role [`Cosmos DB Built-in Data Contributor`](https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#built-in-role-definitions) for `vehicle-state` container. In that case, the role `Cosmos DB Built-in Data Contributor` should be assigned to the SMI of `ca-traffic-control-service` on Cosmos DB container `vehicle-state` only (like you have done in this assignment).

#### Azure Service Bus

Fine colletion service needs only to consume messages from the service bus topic `test` using subscription `fine-collection-service`. It needs only the role `Azure Service Bus Data Receiver` on the service bus topic subscription `fine-collection-service`. It does not need to be able to send messages to the topic. So it does not need the role `Azure Service Bus Data Sender`.

Traffic control server needs only to publish messages to the service bus topic `test`. It needs only the role `Azure Service Bus Data Sender` on the service bus topic `test`. It does not need to be able to consume messages from the topic. So it does not need the role `Azure Service Bus Data Receiver`.

To respect the principle of least privilege, the role `Azure Service Bus Data Receiver` should be assigned to the SMI of `ca-fine-collection-service` on service bus topic subscription `fine-collection-service` only and not on the service bus topic `test`. The role `Azure Service Bus Data Sender` should be assigned to the SMI of `ca-traffic-control-service` on service bus topic `test` only.

{: .note }
> If you use the receiver and the sender roles, fine collection service Dapr sidecar will not be able to create the subscription for fine collection service. Therefore you need to create the subscription before assigning the role to it and create the container app. You need also to set the metadata `disableEntityManagement` to `true` in the `pubsub` component manifest to [disable the automatic creation of the subscription by Dapr](https://v1-9.docs.dapr.io/reference/components-reference/supported-pubsub/setup-azure-servicebus/#spec-metadata-fields).
> 

### Effect of assigning UMI

In this assignment instead of using two SMI to access the service bus, we use a single UMI that has the role `Azure Service Bus Data Owner` on service bus itself. This is not a good practice because it gives more permissions than needed to the container apps:
- Both fine collection service and traffic control service can access and manage all topics, queues and subscriptions in the service bus.
- They can both send and receive messages.
- It means they could access data for which they are not authorized and manage the service bus in a way that could impact other workloads.

In a real world scenario, you should carrefully consider the [effect of assigning UMI](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations#consider-the-effect-of-assigning-managed-identities-to-azure-resources) to a container app. When you are assigning a UMI to a container app, you are giving all the permissions of the UMI to the container app.

### Effect of SMI lifecycle

[SMI are created and deleted along resources](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/managed-identity-best-practice-recommendations#choosing-system-or-user-assigned-managed-identities), therefore role assignement cannot be created in advance. The consequences are multiple for container apps:

- The deployment of the container app can fail because the user creating the resource does not have the permission to create role assignment.
- The application deployed to the container apps required the role to be assigned to the SMI before starting. This is for example the case for Dapr components. If the role is not assigned when the application starts, the application will fail. After several minutes, the role assignment will be created and the application will start. This is not the optimal for production workloads.

There are several solutions to this problem:
- Create 1 UMI per container app and assign the role to the UMI prior to the creation of the container app. The consequence is that you'll need to explicitely delete the UMI when you delete the container app.
- Create a container app with a dummy image (e.g. [hello-world](https://learn.microsoft.com/en-us/azure/container-apps/get-started?tabs=bash#create-and-deploy-the-container-app)) and a SMI. Assign the role to the SMI. Then update the container app with the real image. This could be seen as an upsert operation. If you are using this solution, you should look at the [application lifecycle management](https://learn.microsoft.com/en-us/azure/container-apps/application-lifecycle-management) and should use [multiple revisions](https://learn.microsoft.com/en-us/azure/container-apps/revisions#multiple-revisions) to ensure zero downtime and that the hello-world image is not exposed to the public.

### Effect of UMI on Dapr components

Dapr components can use managed identity of the scoped container apps to access Azure services. For example, it can use the managed identity of fine collection service to access the service bus. When you use managed identity with a Dapr Component, you don't include secret information in the component manifest. However, for UMI, you need to provide the [`azureClientId` in the component manifest](https://learn.microsoft.com/en-us/azure/container-apps/dapr-overview?tabs=bicep1%2Cyaml#using-managed-identity). This is not the case for SMI.

There is a consequence to this: you cannot have 1 UMI for fine collection service and 1 UMI for traffic control service to access the Azure Service Bus with the same Dapr `pubsub` component. As `azureClientId` is requested in the component manifest, you will need to create two `pubsub` components like: `pubsub-send` and `pubsub-receive`. One for sending messages and one for receiving messages. Each one would use a different UMI.

### 4000 role assignements per subscription

There is a [limit of 4000 role assignments per subscription](https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-portal#list-number-of-role-assignments). When you have a lot of workloads in the same subscription, you could reach this limit. In that case, you could consider to use UMI instead of SMI and to grant broader permissions to the UMI. This could result in a violation of the principle of least privilege. You should consider this carefully. You could also consider to use multiple subscriptions.

### Conclusion

As written at the begining of this section, the choice between SMI and UMI can be challenging. You need to weigh pros and cons to do the best choice for your workload and your organization.

In this workshop, we have used both SMI and UMI to demonstrate the use of both types of managed identities. These choices are not necessarily the best choices for your workload and your organization.

For real workload you should evaluate carefully the choice between SMI and UMI and all the considerations listed in this section. At the end the decision is yours to make.
