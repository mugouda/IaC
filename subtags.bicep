param location string = resourceGroup().location
param spIdentityResourceId string
param commonResourceTags object

resource getSubscriptionTagsScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'get-subscription-tags'
  location: location
  tags: commonResourceTags
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${spIdentityResourceId}': {}
    }
  }
  properties: {
    azCliVersion: '2.40.0'
    retentionInterval: 'P1D'
    cleanupPreference: 'OnSuccess'
    timeout: 'PT30M'
    environmentVariables: [
      {
        name: 'SUB_ID'
        value: subscription().id
      }
    ]
    scriptContent: '''
      tags=$(az tag list --resource-id ${SUB_ID} --query 'properties.tags')
      echo $tags > $AZ_SCRIPTS_OUTPUT_PATH
    '''
  }
}

output subscriptionDnsLabel string = getSubscriptionTagsScript.properties.outputs.x//['dns-label']
