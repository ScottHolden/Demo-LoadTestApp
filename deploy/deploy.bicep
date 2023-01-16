param prefix string = 'LoadTestApp'
param location string = resourceGroup().location

var uniqueName = '${prefix}${uniqueString(prefix, resourceGroup().id)}'
var dbName = 'BooksDB'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: uniqueName
  location: location
  properties: {}
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: uniqueName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: uniqueName
  location: location
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
    family: 'EP'
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: 20
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: toLower(uniqueName)
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource msi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: uniqueName
  location: location
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: toLower(uniqueName)
  location: location
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      principalType: 'Application'
      login: msi.name
      sid: msi.properties.clientId
      tenantId: msi.properties.tenantId
    }
  }
  resource allowedIps 'firewallRules@2021-08-01-preview' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      endIpAddress: '0.0.0.0'
      startIpAddress: '0.0.0.0'
    }
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: dbName
  location: location
  parent: sqlServer
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 10
  }
  properties: {
    requestedBackupStorageRedundancy: 'Local'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: uniqueName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      connectionStrings: [
        {
          name: 'SqlDb'
          connectionString: 'Data Source=${sqlServer.properties.fullyQualifiedDomainName}; Initial Catalog=${sqlDb.name}; Authentication=Active Directory Managed Identity; Encrypt=True; User Id=${msi.properties.clientId}'
          type: 'SQLAzure'
        }
      ]
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(uniqueName)
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet-isolated'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${msi.id}': {}
    }
  }
}

resource loadTest 'Microsoft.LoadTestService/loadTests@2022-12-01' = {
  name: uniqueName
  location: location
  properties: {}
}

output loadTestName string = loadTest.name
output functionAppName string = functionApp.name
