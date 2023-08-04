1. Open a terminal window.

1. Azure Cosmos DB account for SQL API is a globally distributed multi-model database service. This account needs to be globally unique. Use the following command to generate a unique name:

    - Linux/Unix shell:
       
        ```bash
        UNIQUE_IDENTIFIER=$(LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 5)
        COSMOS_DB="cosno-dapr-workshop-java-$UNIQUE_IDENTIFIER"
        echo $COSMOS_DB
        ```

    - Powershell:
    
        ```powershell
        $ACCEPTED_CHAR = [Char[]]'abcdefghijklmnopqrstuvwxyz0123456789'
        $UNIQUE_IDENTIFIER = (Get-Random -Count 5 -InputObject $ACCEPTED_CHAR) -join ''
        $COSMOS_DB = "cosno-dapr-workshop-java-$UNIQUE_IDENTIFIER"
        $COSMOS_DB
        ```

1. Create a Cosmos DB account for SQL API:

    ```bash
    az cosmosdb create --name $COSMOS_DB --resource-group rg-dapr-workshop-java --locations regionName=eastus failoverPriority=0 isZoneRedundant=False
    ```

    {: .important }
    > The name of the Cosmos DB account must be unique across all Azure Cosmos DB accounts in the world. If you get an error that the name is already taken, try a different name. In the following steps, please update the name of the Cosmos DB account accordingly.

1. Create a SQL API database:

    ```bash
    az cosmosdb sql database create --account-name $COSMOS_DB --resource-group rg-dapr-workshop-java --name dapr-workshop-java-database
    ```

1. Create a SQL API container:

    ```bash
    az cosmosdb sql container create --account-name $COSMOS_DB --resource-group rg-dapr-workshop-java --database-name dapr-workshop-java-database --name vehicle-state --partition-key-path /partitionKey --throughput 400
    ```

    {: .important }
    > The partition key path is `/partitionKey` as mentionned in [Dapr documentation](https://docs.dapr.io/reference/components-reference/supported-state-stores/setup-azure-cosmosdb/#setup-azure-cosmosdb).
    >

1. Get the Cosmos DB account URL and note it down. You will need it in the next step and to deploy it to Azure.
   
    ```bash
    az cosmosdb show --name $COSMOS_DB --resource-group rg-dapr-workshop-java --query documentEndpoint -o tsv
    ```

1. Get the master key and note it down. You will need it in the next step and to deploy it to Azure.

    ```bash
    az cosmosdb keys list --name $COSMOS_DB --resource-group rg-dapr-workshop-java --type keys --query primaryMasterKey -o tsv
    ```