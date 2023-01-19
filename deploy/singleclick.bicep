param prefix string = 'LoadTestApp'
param location string = resourceGroup().location
param zipDeploy string = ''

module deploy 'deploy.bicep' = {
  name: '${deployment().name}-deploy'
  params: {
    location: location
    prefix: prefix
    zipDeploy: zipDeploy
  }
}

output functionAppName string = deploy.outputs.functionAppName
output loadTestName string = deploy.outputs.loadTestName
