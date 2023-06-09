param location string 
param clusterName string 
param nodeCount int 
param vmSize string
param sourceKind string

var url = 'https://asademodev.blob.${environment().suffixes.storage}/dev'
resource aks 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: clusterName
  location: location
  tags: {
    runDuring:'businessHours'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        vmSize: vmSize
        mode: 'System'
      }
    ]

  }
}

resource flux 'Microsoft.KubernetesConfiguration/extensions@2021-09-01' = {
  name: 'flux'
  scope: aks
  properties: {
    extensionType: 'microsoft.flux'
    scope: {
      cluster: {
        releaseNamespace: 'flux-system'
      }
    }
    configurationSettings: {
      'multiTenancy.enforce': 'false'
    }
    autoUpgradeMinorVersion: true
  
  }
}
resource fluxConfigGit 'Microsoft.KubernetesConfiguration/fluxConfigurations@2021-11-01-preview' = {
  name: 'flux-bootstrap'
  scope: aks
  dependsOn: [
    flux
  ]
  properties: {
    scope: 'cluster'
    namespace: 'flux-system'
    sourceKind: sourceKind
    suspend: false
    configurationProtectedSettings: {
      username: 'aGVyYmVydGhtYXM='
      password: 'Z2hwX2JYVFNaYUtJWkhhQk9DQjNhZUVKb0xBTE9NTG5WZzBhTFk4Zg=='
    }
    gitRepository: {
      url: 'https://github.com/herberthmas/kubernetes-flux'
      timeoutInSeconds: 60
      syncIntervalInSeconds: 120
      localAuthRef: 'flux-bootstrap-genkey'
      repositoryRef: {
        branch: 'main'
      }

    }
    kustomizations: {
      folder: {
        path: 'clusters'
        dependsOn: []
        timeoutInSeconds: 60
        syncIntervalInSeconds: 120
        //retryIntervalInSeconds: 60
        validation: 'none'
        prune: true
      }
      
    }
  }
} 
output url string = url
