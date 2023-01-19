$artifactsFolder = ".\.artifacts"
$bicepPath = ".\deploy\singleclick.bicep"
$csprojPath = ".\src\DemoApp\DemoApp.csproj"

Write-Host "Cleaning up old artifacts..."

if (Test-Path -Path $artifactsFolder -PathType Container) {
    Remove-Item -Path $artifactsFolder -Recurse -ErrorAction Stop | Out-Null
}

New-Item -Path $artifactsFolder -ItemType Directory -ErrorAction Stop | Out-Null


Write-Host "Checking for Bicep updates..."

& az bicep upgrade
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error whilst upgrading Bicep, is the Azure CLI & Bicep installed?" -ErrorAction Stop
}


Write-Host "Building Bicep template..."

$template = Join-Path $artifactsFolder "deploy.json"

& az bicep build -f $bicepPath --outfile $template

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error whilst building Bicep template." -ErrorAction Stop
}


Write-Host "Publishing Azure Function..."

$functionStaging = Join-Path $artifactsFolder "funcTemp"
New-Item -Path $functionStaging -ItemType Directory -ErrorAction Stop | Out-Null

& dotnet publish -c Release --output $functionStaging $csprojPath

if ($LASTEXITCODE -ne 0) {
    Write-Error "Error whilst publishing project." -ErrorAction Stop
}

Write-Host "Zipping Azure Function..."

$functionZip = Join-Path $artifactsFolder "function.zip"
Compress-Archive -Path (Join-Path $functionStaging "*") -DestinationPath $functionZip -ErrorAction Stop

Remove-Item -Path $functionStaging -Recurse -ErrorAction Stop | Out-Null

Write-Host "Template at: $template ($((Get-Item $template).length/1KB))"
Write-Host "Function at: $functionZip ($((Get-Item $functionZip).length/1KB))"