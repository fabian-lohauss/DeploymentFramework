function Remove-DfAdoPersonalAccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$OrganizationName,

        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [string]$KeyVaultName
    )

    try {
        $ExistingToken = Get-DfAdoPersonalAccessToken -OrganizationName $OrganizationName -DisplayName $DisplayName

        if ($null -eq $ExistingToken) {
            return
        }

        if ($ExistingToken.PatTokens.Count -gt 1) {
            throw [Exception]::new("There are multiple personal access tokens with the same display name '{0}'" -f $DisplayName)
        }

        $Method = "Delete"
        $tokenBody = @{
            displayName     = $displayName
            authorizationId = $ExistingToken.authorizationId
        }

        $Result = Invoke-DfAdoRestMethod -OrganizationName $OrganizationName -Api "tokens/pats" -Method $Method -Body $tokenBody 
    }
    catch {
        throw [Exception]::new(("Failed to remove personal access token '{0}': {1}" -f $DisplayName, $_.Exception.Message), $_.Exception)
    }
    
}