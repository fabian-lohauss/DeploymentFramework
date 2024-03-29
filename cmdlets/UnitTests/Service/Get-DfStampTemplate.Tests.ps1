BeforeAll {
    Import-Module $PSScriptRoot/../../src/DeploymentFramework.psd1 -Force
}

Describe "Get-DfStampTemplate" {
    Context "valid templates '<GivenFolders>'" -ForEach @(
        @{ GivenFolders = @("TestDrive:/Stamps/AStamp"); ExpectedTemplates = @( @{ Name = "AStamp" } ) }
        @{ GivenFolders = @("TestDrive:/Stamps/AStamp", "TestDrive:/Stamps/SecondStamp"); ExpectedTemplates = @( @{ Name = "AStamp" }, @{ Name = "SecondStamp" } ) }
    ) {
        BeforeAll {
            foreach ($Folder in $GivenFolders) {
                New-Item $Folder -ItemType Directory -Force | Out-Null
            }
            Mock Get-DfProject { return @{ StampFolder = "TestDrive:/Stamps" } } -ModuleName DeploymentFramework
        }

        It "should not throw" {
            { Get-DfStampTemplate } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Get-DfStampTemplate 
            $Error | Should -HaveCount 0
        }

        It "should return the expected number of templates" {
            Get-DfStampTemplate | Should -HaveCount $ExpectedTemplates.Count
            Should -Invoke Get-DfProject -ModuleName DeploymentFramework
        }

        It "should return the template '<Name>'" -TestCases $ExpectedTemplates {
            (Get-DfStampTemplate).Name | Should -Contain $Name
            Should -Invoke Get-DfProject -ModuleName DeploymentFramework
        }
    }

    Context "no templates" -ForEach @(
        @{ GivenFolders = @() }
        @{ GivenFolders = @("TestDrive:/Stamps") }
    ) {
        BeforeAll {
            foreach ($Folder in $GivenFolders) {
                New-Item $Folder -ItemType Directory -Force | Out-Null
            }
            Mock Get-DfProject { return @{ StampFolder = "TestDrive:/Stamps" } } -ModuleName DeploymentFramework
        }

        It "should not throw" {
            { Get-DfStampTemplate } | Should -Not -Throw
        }

        It "should not have errors" {
            $Error.Clear()
            Get-DfStampTemplate 
            $Error | Should -HaveCount 0
        }

        It "should return null" {
            Get-DfStampTemplate | Should -Be $null
            Should -Invoke Get-DfProject -ModuleName DeploymentFramework
        }
    }    
}