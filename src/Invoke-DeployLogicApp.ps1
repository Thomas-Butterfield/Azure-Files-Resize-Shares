<#
.SYNOPSIS
    Deploy an Azure Logic with using a GitHub Actions Pipeline

.DESCRIPTION
    Script is executed from a GitHub Actions pipeline and the Service Principal App Id,
    Secret and Tenant Id are supplied using repository secrets in YML pipeline.

.EXAMPLE
    PS> .\Invoke-DeployLogicApp.ps1 -Username myuser@onmicrosoft.com -Secret ######### -TenantId ######### -SubscriptionName subscription-name

.NOTES
    Filename: Invoke-DeployLogicApp.ps1
    Author: Thomas Butterfield
    Modified date: 2023-03-14
    Version 1.0
#>

param (
    [Parameter(Mandatory=$true)][string]$AppId,
    [Parameter(Mandatory=$true)][string]$AppSecret,
    [Parameter(Mandatory=$true)][string]$TenantId,
    [Parameter(Mandatory=$true)][string]$SubscriptionId
)

Write-Host "Installing and Importing Az.Resources Module"

Install-Module Az.Resources
Import-Module Az.Resources

Write-Host "Logging in using Azure Service Principal"

$user = $Username
$pWord = ConvertTo-SecureString -String $Secret -AsPlainText -Force
$tenant = $TenantId
$credential = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $user,$pWord

$null = Connect-AzAccount -Credential $credential -Tenant $tenant -ServicePrincipal -Subscription $SubscriptionId -ErrorAction Stop

If ((Get-AzContext).Subscription -match $SubscriptionID){

    $deployParams = @{
        ResourceGroupName       = 'rg-storage-account-logic-app'
        SubscriptionId          = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx'
        Name                    = 'logic-app-storage-accounts-deployment'
        TemplateFile            = '.\Bicep\DeployLogicApp.bicep'
        ###
        TemplateParameterObject = @{
            LogicAppName      = 'logic-app-storage-accounts'
            TargetFreeSpaceGB = 50
            StorageAccountIds = @(
            '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx/resourceGroups/rg-us1-my-app1/providers/Microsoft.Storage/storageAccounts/storageact1' 
            '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxx/resourceGroups/rg-us1-my-app2/providers/Microsoft.Storage/storageAccounts/storageact2'
            ) # The system assigned identity of the Logic App must have the Contributor role on the Storage Accounts.
        }
    }

    New-AzResourceGroupDeployment @deployParams

}