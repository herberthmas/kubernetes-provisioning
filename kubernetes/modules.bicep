param location string = resourceGroup().location
param vmSize string = 'standard_d16ads_v5'


@description('Specify the environment')
@allowed([
  'Prod'
  'Dev'
])
param environment string
@description('Specify the storage for the code')
@allowed([
  'GitRepository'
  'Bucket'
]) 
param sourceKind string
param clusterName string = 'aks-HmgDemo${environment}'
param nodeCount int = (environment == 'Dev') ? 1 :3
param gitUser string
@secure()
param gitPassword string

module aksModule 'kubernetes.bicep' = {
  name: 'aksDeploy'
  params: {
    location: location
    clusterName:clusterName
    vmSize:vmSize
    nodeCount:nodeCount
    sourceKind:sourceKind
    gitUserName:gitUser
    gitToken:gitPassword
  }

}

output clusterName string = clusterName 
