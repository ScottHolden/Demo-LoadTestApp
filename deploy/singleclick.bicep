param prefix string = 'LoadTestApp'
param location string = resourceGroup().location
param zipDeploy string = 'https://github.com/ScottHolden/Demo-LoadTestApp/blob/main/.artifacts/function.zip?raw=true'

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
