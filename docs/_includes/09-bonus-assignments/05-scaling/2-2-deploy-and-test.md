## Step 1: Set the authentication

To be able to determine the number of messages on the `test` topic, KEDA needs to be able to connect to the service bus. To do so, you need to create a secret in `ca-fine-colelction-service` container app. Currently [scale rules of Container Apps support only secret references](https://learn.microsoft.com/en-us/azure/container-apps/scale-app?pivots=azure-cli#authentication-1). To know more about secret management in Azure ontainer Apps, see [this page](https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets?tabs=azure-cli).

{% if include.showWithoutSecret %}

Centralizing secrets in Azure Key Vault allows you to control their distribution. However, if you didn't do the bonus assignments on [secret store]({{ site.baseurl }}{% link modules/09-bonus-assignments/03-secret-store/3-use-secret-in-dapr-component.md %}) and on [managed identities]({{ site.baseurl }}{% link modules/09-bonus-assignments/04-managed-identities/index.md %}), you can set the connection string of the service bus directly in the container app secret. If you have done both bonus assignments, you can refer to a secret in the key vault.

### Set the connection string directly in the secret

To create a secret for service bus connection string, enter the following command in the terminal:

```bash
az containerapp secret set \
  --name ca-fine-collection-service \
  --resource-group rg-dapr-workshop-java \
  --secrets "sb-connect-str-scrt=<service-bus-connection-string>"
```

Where `<service-bus-connection-string>`  should be replaced by the connection string of the service bus.

{: .note }
> The length of the secret name is limited to 20 characters when set using Azure CLI. Using the portal or a Bicep template, you can use longer secret names and therefore more meaningfull names.
>

### Refer to the connection string in the key vault

{% endif %}

Centralizing secrets in Azure Key Vault allows you to control their distribution. You are going to create a secret in the container app that is referencing the secret `azSericeBusconnectionString` in the key vault. This secret contains the connection string of the service bus. To access this secret you'll set that the container apps need to use the system-managed identity (SMI) of the container app. This is SMI has the role `Key Vault Secrets User`. It means the container app can read all the secrets in the key vault.

1. Get the URI of the secret `azSericeBusconnectionString` that service bus connection string:

    - Linux/Unix shell:

        ```bash
        SB_CONNECTION_STRING_SECRET_URI=$(az keyvault secret show \
          --vault-name $KEY_VAULT \
          --name azSericeBusconnectionString \
          --query "id" \
          -o tsv)
        ```

    - PowerShell:

        ```powershell
        $SB_CONNECTION_STRING_SECRET_URI = az keyvault secret show `
          --vault-name "$KEY_VAULT" `
          --name "azSericeBusconnectionString" `
          --query "id" `
          -o tsv
        ```

    When getting the the URI of the secret, you get the reference to a specific version. If you want that the container app uses the latest version of the secret (updated every 30 minutes), please follow the instructions in the [documentation](https://learn.microsoft.com/en-us/azure/container-apps/manage-secrets?tabs=azure-cli#key-vault-secret-uri-and-secret-rotation).

1. Set the secret in the container app:

    ```bash
    az containerapp secret set \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --secrets "sb-connect-str-scrt=keyvaultref:$SB_CONNECTION_STRING_SECRET_URI,identityref:system"
    ```
    
    The structure is `<secret-name>=keyvaultref:<key-vault-secret-URI>,identityref:<UMI-ID | system>` where:

      - `<secret-name>` is the name of the secret in the container app.
      - `<key-vault-secret-URI>` is the URI of the secret in the key vault.
      - `<UMI-ID | system>` is the identity that is used to access the secret. It can be either `system` for a system-assigned managed identity (SMI) or the resource id of a user-managed identity (UMI).

{: .note }
> The length of the secret name is limited to 20 characters when set using Azure CLI. Using the portal or a Bicep template, you can use longer secret names and therefore more meaningfull names.
>

## Step 2: Set the scale rule

To set the scale rule, enter the following command:

```bash
az containerapp update \
  --name ca-fine-collection-service \
  --resource-group rg-dapr-workshop-java \
  --min-replicas 0 \
  --max-replicas 5 \
  --scale-rule-name azure-servicebus-topic-test-rule \
  --scale-rule-type azure-servicebus \
  --scale-rule-metadata "subscriptionName=fine-collection-service" \
                        "topicName=test" \
                        "messageCount=10" \
  --scale-rule-auth "connection=sb-connect-str-scrt"
```

This command creates a scale rule named `azure-servicebus-topic-test-rule` for `ca-fine-collection-service` container app. The rule is based on the number of messages on the `test` topic of the `fine-collection-service` subscription. The rule is triggered when there are 10 messages on the topic. The connection string of the service bus is stored in the secret named `sb-connect-str-scrt`. The minimum number of replicas is set to 0 and the maximum number of replicas is set to 5.

You can now go to the portal and check that the scale rule has been created. To do so, go to the `ca-fine-collection-service` container app and click on the `Scale and replicas` in `Application` section. You should see the following:

![Scale rule]({{include.relativeAssetsPath}}images/scale-rule.png)

You can also check that the scale rule has been created by entering the following command in the terminal:

```bash
az containerapp show \
  --name ca-fine-collection-service \
  --resource-group rg-dapr-workshop-java \
  --query "properties.template.scale" \
  -o json
```

## Step 3: Test the scaling

1. If the simulation is running, stop the simulation.

1. After a few minutes, you should see that the number of replicas has decreased to zero.

1. Check the list of replicas using the following command:

    ```bash
    az containerapp replica list \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java
    ```

    If there is no replica, the answer should be:

    ```json
    []
    ```

1. When the number of replicas is zero, start the simulation again.

    1. Set the following environment variable:
   
        - Linux/Unix shell:

            ```bash
            export TRAFFIC_CONTROL_SERVICE_BASE_URL=https://$TRAFFIC_CONTROL_SERVICE_FQDN
            ```

        - PowerShell:

            ```powershell
            $env:TRAFFIC_CONTROL_SERVICE_BASE_URL = "https://$TRAFFIC_CONTROL_SERVICE_FQDN"
            ```

    1. In the root folder of the simulation (`Simulation`), enter the following command:

        ```bash
        mvn spring-boot:run
        ```

1. After a few minutes, you should see that the number of replicas has increased.

    ```bash
    az containerapp replica list \
      --name ca-fine-collection-service \
      --resource-group rg-dapr-workshop-java \
      --query "[].name" \
      -o json
    ```

### Increase the number of messages

To increase the number of messages on the topic, you can either:

- Run multiple simulation in parallel.
- Send batch of messages to the topic using the [Azure portal](https://portal.azure.com).

To send batch of messages using the portal, follow these steps:

1. Go to the service bus `sb-dapr-workshop-java-...` in the portal.

1. Select the `Topics` in the `Entities` section.

1. Select the `test` topic.

1. Select the `Service Bus Explorer`

1. Click on `Send messages`

1. Select `Content type`: `application/json`

1. Paste the following JSON in the `Message Body`

    ```json
    {
      "data": {
        "excessSpeed": 45,
        "licenseNumber": "9-HGN-5",
        "roadId": "A12",
        "timestamp": "2023-08-04T17:47:48.1267658"
      },
      "datacontenttype": "application/json",
      "id": "67c0e273-5536-404d-b43b-8f839739f12f",
      "pubsubname": "pubsub",
      "source": "traffic-control-service",
      "specversion": "1.0",
      "time": "2023-08-04T15:47:48Z",
      "topic": "test",
      "traceid": "00-c698158cb6e49814d850311642b85c2e-d979c6869ccd347a-01",
      "traceparent": "00-c698158cb6e49814d850311642b85c2e-d979c6869ccd347a-01",
      "tracestate": "",
      "type": "com.dapr.event.sent"
    }
    ```

1. In the bottom, check `Repeat send` and set `Number of messages` to `10000`.

1. Click on `Send`

If the amount of replicas does not increased, you can wait a few minutes or send more messages.

### Check the replica count in the portal

`Replica Count` is a metric that is available in the portal. To check the replica count, follow these steps:

1. Go to the `ca-fine-collection-service` container app in the portal.

1. Select `Metrics` in the `Monitoring` section.

1. Select `Replica Count` in the `Metric` dropdown.

1. Select `1h` in the `Time range` dropdown.

You should see something like this:

![Replica count metric]({{include.relativeAssetsPath}}images/replica-count-metric.png)