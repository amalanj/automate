
## Install AzureRM module
#Install-Module -Name AzureRM -AllowClobber -Force

## Connect AzureAD
#$Credential = Get-Credential
#Connect-AzureAD -Credential $Credential
#Connect-AzureAD 
# login
#Login-AzureRmAccount
# perform other Azure operations...

#$currentAzureContext = Get-AzureRmContext
#$tenantId = $currentAzureContext.Tenant.Id
#$accountId = $currentAzureContext.Account.Id
#Connect-AzureAD -TenantId $tenantId -AccountId $accountId

Connect-AzAccount

## Resource Group access to users based on Role
#New-AzureRmRoleAssignment -ResourceGroupName $rg -SignInName $newuser -RoleDefinitionName $owneraccess
New-AzRoleAssignment -ResourceGroupName rg1 -SignInName allen.young@live.com -RoleDefinitionName Reader -AllowDelegation

## Keyvault access to users based on Role
#New-AzureRmRoleAssignment -SignInName $newuser -RoleDefinitionName $readeraccess -Scope $kvScope
New-AzRoleAssignment -SignInName $newuser -RoleDefinitionName $readeraccess -Scope $kvScope

## Adding new secret to Keyvault
$Secret = ConvertTo-SecureString -String $passwd -AsPlainText -Force
#Set-AzureKeyVaultSecret -VaultName $kv -Name 'ITSecret' -SecretValue $Secret
Set-AzKeyVaultSecret -VaultName $kv -Name 'ITSecret' -SecretValue $Secret

## Set Access Policy to Keyvault
#Set-AzureRmKeyVaultAccessPolicy -VaultName $kv -UserPrincipalName $newuser -PermissionsToKeys create,import,delete,list -PermissionsToSecrets set,delete -PassThru
Set-AzKeyVaultAccessPolicy -VaultName $kv -UserPrincipalName $newuser -PermissionsToKeys create,import,delete,list -PermissionsToSecrets set,delete -PassThru

## Set Certificate Policy to Keyvault
#Set-AzureKeyVaultCertificatePolicy -VaultName $kv -Name $newuserid -SecretContentType "application/x-pkcs12" -SubjectName "CN=amalandxcoutlookcom.onmicrosoft.com" -IssuerName "Self" -ValidityInMonths 6 -ReuseKeyOnRenewal $True -PassThru
Set-AzKeyVaultCertificatePolicy -VaultName $kv -Name $newuserid -SecretContentType "application/x-pkcs12" -SubjectName "CN=amalandxcoutlookcom.onmicrosoft.com" -IssuerName "Self" -ValidityInMonths 6 -ReuseKeyOnRenewal $True -PassThru

## Add client Secret tp Azure AD App Registrations
$startDate = Get-Date
$endDate = $startDate.AddYears(2)
$SecureStringPassword = ConvertTo-SecureString -String "password" -AsPlainText -Force
#$aadAppKeyPwd = New-AzureADApplicationPasswordCredential -ObjectId $appObjectId -CustomKeyIdentifier "Primary" -StartDate $startDate -EndDate $endDate
New-AzADAppCredential -ObjectId $appObjectId -Password $SecureStringPassword -CustomKeyIdentifier "Primary" -StartDate $startDate -EndDate $endDate

## Add User to Active Directory
#$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
#$PasswordProfile.Password = $passwd
#New-AzureADUser -DisplayName "New User" -PasswordProfile $PasswordProfile -UserPrincipalName "NewUser@amalandxcoutlookcom.onmicrosoft.com" -AccountEnabled $true -MailNickName "Newuser"
$SecureStringPassword = ConvertTo-SecureString -String $passwd -AsPlainText -Force
New-AzADUser -DisplayName "MyDisplayName" -UserPrincipalName $aduser -Password $SecureStringPassword -MailNickname "MyMailNickName"

## Add Group tp Active Directory
#New-AzureADGroup -DisplayName "DevADGroup" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
New-AzADGroup -DisplayName "DevADGroup" -MailNickName "NotSet"

Import-Module Az.Resources # Imports the PSADPasswordCredential object
$credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password=$passwd}
$sp = New-AzAdServicePrincipal -DisplayName automationSP -PasswordCredential $credentials
