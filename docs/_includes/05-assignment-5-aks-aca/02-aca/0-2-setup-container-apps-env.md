<!-- Require 'include.showObservability' that set if Dapr telemetry is displayed
or not -->
A [container apps environment](https://learn.microsoft.com/en-us/azure/container-apps/environment) acts as a secure boundary around our container apps. Containers deployed on the same environment use the same virtual network and write the log to the same logging destionation, in our case: Log Analytics workspace.

{% if include.showObservability %}

To create the container apps environment with Dapr service-to-service telemetry, you need to set `--dapr-instrumentation-key` parameter to the Application Insights instrumentation key. Use the following command to create the container apps environment:

```bash
az containerapp env create \
  --resource-group rg-dapr-workshop-java \
  --location eastus \
  --name cae-dapr-workshop-java \
  --logs-workspace-id "$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID" \
  --logs-workspace-key "$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET" \
  --dapr-instrumentation-key "$INSTRUMENTATION_KEY"
```

{% else %}

{: .important-title }
> Dapr Telemetry
> 
> If you want to enable Dapr telemetry, you need to create the container apps environment with Application Insights. You can follow these instructions instead of the instructions below: [(Optional) Observability with Dapr using Application Insights]({{ site.baseurl }}{% link modules/05-assignment-5-aks-aca/02-aca/2-observability.md %})
>

Create the container apps environment with the following command:

```bash
az containerapp env create \
  --resource-group rg-dapr-workshop-java \
  --location eastus \
  --name cae-dapr-workshop-java \
  --logs-workspace-id "$LOG_ANALYTICS_WORKSPACE_CUSTOMER_ID" \
  --logs-workspace-key "$LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET"
```

{% endif %}

{: .note }
> Some Azure CLI commands can take some time to execute. Don't hesitate to have a look at the next assignments / steps to know what you will have to do. And then, come back to this one when the command is done and execute the next one.
>
