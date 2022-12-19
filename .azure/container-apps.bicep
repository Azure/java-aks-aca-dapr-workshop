@description('The name of the container apps environment.')
param containerAppsEnvironmentName string

@description('The location of the container apps environment.')
param location string = resourceGroup().location

@description('The name of the log analytics workspace.')
param logAnalyticsWorkspaceName string
@description('The name of the application insights.')
param appInsightsName string

@description('The name of the key vault.')
param keyvaultName string
@description('The client id of the key vault.')
param keyvaultClientId string
@secure()
@description('The client secret of the key vault.')
param keyvaultClientSecret string

@description('The name of the secret in the key vault for the Service Bus connection string.')
param seviceBusConnectionStringKeyvaultSecretName string = 'service-bus-connection-string'
@secure()
@description('The connection string of the service bus.')
param serviceBusConnectionString string
@description('The name of the topic in the service bus.')
param serviceBusTopicName string = 'test'


@description('The name of the Cosmos DB database.')
param cosmosDbDatabaseName string
@description('The name of the Cosmos DB collection/container.')
param cosmosDbCollectionName string
@description('The name of the secret in the key vault for the Cosmos DB account key.')
param cosmosDbAccountKeyKeyvaultSecretName string = 'cosmos-db-account-key'
@description('The name of the secret in the key vault for the Cosmos DB account URL.')
param cosmosDbAccountUrlKeyvaultSecretName string = 'cosmos-db-account-url'

@description('The name of the Azure Container Registry.')
param containerRegistryName string
@description('The tag of the images.')
param tag string = 'latest'
@description('The name of the image for the vehicle registration service.')
param vehicleRegistrationServiceImageName string = 'vehicle-registration-service'
@description('The name of the image for the fine collection service.')
param fineCollectionServiceImageName string = 'fine-collection-service'
@description('The name of the image for the traffic control service.')
param trafficControlServiceImageName string = 'traffic-control-service'
@description('The name of the image for the simulation.')
param simulationImageName string = 'simulation'

@description('The name of the service for the vehicle registration service.')
param vehicleRegistrationServiceName string = 'vehicle-registration-service'
@description('The name of the service for the fine collection service.')
param fineCollectionServiceName string = 'fine-collection-service'
@description('The name of the service for the traffic control service.')
param trafficControlServiceName string = 'traffic-control-service'
@description('The name of the service for the simulation.')
param simulationName string = 'simulation'


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: containerAppsEnvironmentName
  location: location
  // Question: what are sku in Container Apps Environment? No documentation on it
  // Second question: what are connected environments? No documentation on it
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    // TODO update to connection string and test it as instrumentation key should be migrated to connection string
    // daprAIConnectionString: appInsights.properties.ConnectionString
  }
}

// https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments/daprcomponents?pivots=deployment-language-bicep
resource secretstoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'secretstore'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'secretstores.azure.keyvault'
    version: 'v1'
    metadata: [
      {
        name: 'vaultName'
        value: keyvaultName
      }
      {
        name: 'azureClientId'
        value: keyvaultClientId
      }
      {
        name: 'azureClientSecret'
        secretRef: 'keyvault-client-secret'
      }
      {
        name: 'azureTenantId'
        value: subscription().tenantId
      }
    ]
    secrets: [
      {
        name: 'keyvault-client-secret'
        value: keyvaultClientSecret
      }
    ]
    scopes: [
      'fine-collection-service'
      'traffic-control-service'
    ]
  }
}

resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'pubsub'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    metadata: [
      {
        name: 'connectionString'
        secretRef: seviceBusConnectionStringKeyvaultSecretName
      }
    ]
    scopes: [
      'fine-collection-service'
      'traffic-control-service'
    ]
    secretStoreComponent: secretstoreComponent.name
  }
}

resource statestoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: 'statestore'
  parent: containerAppsEnvironment
  properties: {
    componentType: 'state.azure.cosmosdb'
    version: 'v1'
    metadata: [
      {
        name: 'url'
        secretRef: cosmosDbAccountUrlKeyvaultSecretName
      }
      {
        name: 'masterKey'
        secretRef: cosmosDbAccountKeyKeyvaultSecretName
      }
      {
        name: 'database'
        value: cosmosDbDatabaseName
      }
      {
        name: 'collection'
        value: cosmosDbCollectionName
      }
      {
        name: 'actorStateStore'
        value: 'true'
      }
    ]
    scopes: [
      'traffic-control-service'
    ]
    secretStoreComponent: secretstoreComponent.name
  }
}

resource vehicleRegistrationService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: vehicleRegistrationServiceName
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'single'
      dapr: {
        enabled: true
        appId: vehicleRegistrationServiceName
        appProtocol: 'http'
        appPort: 6002
        logLevel: 'info'
      }
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.name
          passwordSecretRef: 'container-registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: vehicleRegistrationServiceName
          image: '${containerRegistry.properties.loginServer}/${vehicleRegistrationServiceImageName}:${tag}'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}

resource fineCollectionService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: fineCollectionServiceName
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'single'
      dapr: {
        enabled: true
        appId: fineCollectionServiceName
        appProtocol: 'http'
        appPort: 6001
        logLevel: 'info'
      }
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          // Needed for KEDA scaler for service bus
          name: 'service-bus-connection-string'
          value: serviceBusConnectionString
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.name
          passwordSecretRef: 'container-registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: fineCollectionServiceName
          image: '${containerRegistry.properties.loginServer}/${fineCollectionServiceImageName}:${tag}'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'VEHICLE_REGISTRATION_SERVICE'
              value: vehicleRegistrationServiceName
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            name: 'service-bus-test-topic'
            custom: {
              type: 'azure-servicebus'
              auth: [
                {
                  secretRef: 'service-bus-connection-string'
                  triggerParameter: 'connection'
                }
              ]
              metadata: {
                subscriptionName: fineCollectionServiceName
                topicName: serviceBusTopicName
                messageCount: '10'
              }
            }
          }
        ]
      }
    }
  }
  dependsOn: [
    secretstoreComponent
    pubsubComponent
    vehicleRegistrationService
  ]
}

resource trafficControlService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: trafficControlServiceName
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: false
        targetPort: 6000
      }
      dapr: {
        enabled: true
        appId: trafficControlServiceName
        appProtocol: 'http'
        appPort: 6000
        logLevel: 'info'
      }
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.name
          passwordSecretRef: 'container-registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: trafficControlServiceName
          image: '${containerRegistry.properties.loginServer}/${trafficControlServiceImageName}:${tag}'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
  dependsOn: [
    secretstoreComponent
    pubsubComponent
    statestoreComponent
    fineCollectionService
  ]
}

resource simulationService 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: simulationName
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'single'
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.name
          passwordSecretRef: 'container-registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: simulationName
          image: '${containerRegistry.properties.loginServer}/${simulationImageName}:${tag}'
          resources: {
            cpu: json('0.5')
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'TRAFFIC_CONTROL_SERVICE_BASE_URL'
              value: 'https://${trafficControlService.properties.configuration.ingress.fqdn}'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
