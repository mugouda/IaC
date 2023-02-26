targetScope = 'resourceGroup'

param location string = resourceGroup().location
param principalClientId string
@secure()
param principalSecret string
param networking object
param tagEnvironment string = 'tst'
param notificationEmail string
var resourceSuffix = take(uniqueString(resourceGroup().name), 6)
var shortLocation = 'tst'//loadJsonContent('locations.json')//[location]
var resourceInfix = '${shortLocation}-${tagEnvironment}-fdm'

resource vault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kv-${resourceInfix}-${resourceSuffix}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    tenantId: tenant().tenantId
  }
}

resource clientIdKvSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  //checkov:skip=CKV_AZURE_41:We don't know when the customer's SP credentials will expire
  name: '${vault.name}/clientId'
  properties: {
    value: principalClientId
  }
}

resource clientSecretKvSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  //checkov:skip=CKV_AZURE_41:We don't know when the customer's SP credentials will expire
  name: '${vault.name}/clientSecret'
  properties: {
    value: principalSecret
  }
}

resource tenantIdKvSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  //checkov:skip=CKV_AZURE_41:We don't know when the customer's SP credentials will expire
  name: '${vault.name}/tenantId'
  properties: {
    value: tenant().tenantId
  }
}

// NOTE: no real need for some of these outputs, but parameters needs to be used
output shortLocation string = shortLocation
output notificationEmail string = notificationEmail
output networking object = networking
output resourceSuffix string = resourceSuffix
