BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}


Describe "New-DfAdoPersonalAccessToken" {
    BeforeAll {
        Mock Test-DfAdoPersonalAccessToken { throw "Test-DfAdoPersonalAccessToken should be mocked" } -ModuleName DeploymentFramework -Verifiable
        Mock Set-DfAdoPersonalAccessToken { } -ModuleName DeploymentFramework -Verifiable
    }

    Context "Parameterset" {
        It "should have mandatory paramater OrganizationName " {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "OrganizationName" -Mandatory
        }

        It "should have mandatory paramater DisplayName " {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "PatDisplayName" -Mandatory
        }

        It "should have mandatory paramater scope" {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "Scope" -Mandatory
        }

        It "should have optional paramater KeyVaultName" {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "KeyVaultName" -Type String
        }

        It "should have optional paramater Passthru" {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "Passthru" -Type Switch
        }

        It "should have optional paramater Force" {
            Get-Command New-DfAdoPersonalAccessToken | Should -HaveParameter "Force" -Type Switch
        }
    }

    Context "exception from Invoke-DfAdoRestMethod" {
        BeforeAll {
            Mock Test-DfAdoPersonalAccessToken { return $false } -ModuleName DeploymentFramework -Verifiable
            Mock Set-DfAdoPersonalAccessToken { throw "Set-DfAdoPersonalAccessToken: some exception." } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope CodeRead } | Should -Throw "Failed to create new personal access token 'displayName'"
        }

        It "should have the Set-DfAdoPersonalAccessToken as inner exception" {
            try {
                New-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "displayName" -Scope PackagingRead
                throw "expected exception not thrown"
            }
            catch {
                $_.Exception.InnerException.Message | Should -Be "Set-DfAdoPersonalAccessToken: some exception."
            }
        }
    }
  
    Context "new PAT created successfully" {
        BeforeAll {
            Mock Test-DfAdoPersonalAccessToken { return $false } -ModuleName DeploymentFramework -Verifiable
            Mock Get-Date { return [datetime]"2024-01-01T18:38:34.69Z" } -ModuleName DeploymentFramework -Verifiable
            Mock Set-DfAdoPersonalAccessToken {
                param($PatDisplayName, $Scope)
                $Result = [PSCustomObject]@{
                    patToken      = [PSCustomObject]@{
                        displayName = $PatDisplayName
                        validFrom   = [datetime]"2023-12-31T18:38:34.69Z"
                        validTo     = [datetime]"2024-01-31T18:38:34.69Z"
                        scope       = "vso.packaging"
                        token       = "myNewPatToken"
                    }
                    patTokenError = "none"
                }
                return [PSCustomObject]$Result
            } -ModuleName DeploymentFramework -Verifiable
        }

        It "should return the result with parameter -Passthru" {
            $Pat = New-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -Passthru
            $Pat.displayName | Should -Be "myNewPat"
            [datetime]($Pat.validTo) | Should -Be ([datetime]"2024-01-31T18:38:34.69Z")
            $Pat.scope | Should -Be "vso.packaging"
        }

        It "should not return anything without parameter -Passthru" {
            $Pat = New-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead"
            $Pat | Should -Be $null
        }
    }

    Context "PAT already exists" {
        BeforeAll {
            Mock Test-DfAdoPersonalAccessToken { return $true } -ModuleName DeploymentFramework -Verifiable
            Mock Set-DfAdoPersonalAccessToken { throw "should not be called" } -ModuleName DeploymentFramework -Verifiable
        }

        It "should throw" {
            { New-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" } | Should -Throw "Failed to create new personal access token 'myNewPat': Personal access token already exists"
        }
    }

    Context "-force creates new PAT" {
        BeforeAll {
            Mock Test-DfAdoPersonalAccessToken { return $true } -ModuleName DeploymentFramework -Verifiable
            Mock Remove-DfAdoPersonalAccessToken { } -ModuleName DeploymentFramework -Verifiable
            Mock Set-DfAdoPersonalAccessToken { } -ModuleName DeploymentFramework -Verifiable
        }

        It "should not throw" {
            { New-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "TheKeyvault" -Force } | Should -Not -Throw
        }

        It "should call Remove-DfAdoPersonalAccessToken" {
            New-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "TheKeyvault" -Force
            Assert-MockCalled Remove-DfAdoPersonalAccessToken -Scope It -ParameterFilter { $PatDisplayName -eq "myNewPat" -and $organizationName -eq "organizationName" -and $KeyVaultName -eq "TheKeyvault"  } -ModuleName DeploymentFramework
        }

        It "should call Set-DfAdoPersonalAccessToken" {
            New-DfAdoPersonalAccessToken -organizationName "organizationName" -PatDisplayName "myNewPat" -Scope "PackagingRead" -KeyVaultName "TheKeyvault" -Force
            Assert-MockCalled Set-DfAdoPersonalAccessToken -Scope It -ParameterFilter { $PatDisplayName -eq "myNewPat" -and $organizationName -eq "organizationName" -and "PackagingRead" -eq $scope -and $KeyVaultName -eq "TheKeyvault" } -ModuleName DeploymentFramework
        }
    }
}
