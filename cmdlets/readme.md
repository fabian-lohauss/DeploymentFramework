
```pwsh
Initialize-DfProject | Add-DfEnvironment "dev" -Subscription (Get-AzSubscription).Id 
New-DfComponent "keyvault" | New-Item -Name "main.bicep" -Value @"
param name string = '{uniqueString(resourceGroup().id)}-kv'
param location string = resourceGroup().location
param tenant string = subscription().tenantId

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' = { name: name, location: location, properties: { sku: { family: 'A', name: 'premium' }, tenantId: tenant } }
"@ 

New-DfServiceTemplate "shared" | Add-DfComponent "keyvault"

Get-DfServiceTemplate "shared" | Deploy-DfService 
Get-DfServiceTemplate -Type "workload" -Version 3.1 | Deploy-DfService -StampId 000, 001, 002


```
# Release Management
```pwsh
# creates version '1.0-PreRelease'
New-DfServiceTemplate "shared" 

# gets latest pre-release version and removes pre-release flag --> creates version ('1.0', 'latest')
Get-DfServiceTemplate "shared" -AllowPrerelease | Publish-DfServiceTemplate 

# gets latest released version and creates new pre-release minor version --> '1.1-PreRelease'
Get-DfServiceTemplate "shared" | New-DfServiceTemplate -NewMinorVersion 

# gets latest pre-release version and creates new major version --> '2.0-PreRelease'
Get-DfServiceTemplate "shared" -AllowPrerelease | New-DfServiceTemplate -NewMajorVersion 
```

```yaml
# Service template
{
    "Name": "shared",
    "Version": ["latest", "2.13", "2"]
    "Components": [
        "keyvault": "latest",
        "loadbalancer": "3"
    ]
}
```