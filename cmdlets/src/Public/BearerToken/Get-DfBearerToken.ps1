function Get-DfBearerToken {
    try {
        $context = Get-AzAccessToken -ErrorAction Stop
    } catch {
        throw "Failed to get bearer token: $_"
    }
    $accessToken = $context.Token
    return "Bearer $accessToken"
}