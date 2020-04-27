
## Install AzureRM module
Install-Module -Name AzureRM -AllowClobber -Force

## Connect AzureAD
$Credential = Get-Credential
Connect-AzureAD -Credential $Credential

## Resource Group access to users based on Role
New-AzureRmRoleAssignment -ResourceGroupName $rg -SignInName $newuser -RoleDefinitionName $owneraccess

## Keyvault access to users based on Role
New-AzureRmRoleAssignment -SignInName $newuser -RoleDefinitionName $readeraccess -Scope $kvScope

## Adding new secret to Keyvault
$Secret = ConvertTo-SecureString -String $passwd -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $learnkv -Name 'ITSecret' -SecretValue $Secret

## Set Access Policy to Keyvault
Set-AzureRmKeyVaultAccessPolicy -VaultName $learnkv -UserPrincipalName $newuser -PermissionsToKeys create,import,delete,list -PermissionsToSecrets set,delete -PassThru

## Set Certificate Policy to Keyvault
Set-AzureKeyVaultCertificatePolicy -VaultName $learnkv -Name $newuserid -SecretContentType "application/x-pkcs12" -SubjectName "CN=amalandxcoutlookcom.onmicrosoft.com" -IssuerName "Self" -ValidityInMonths 6 -ReuseKeyOnRenewal $True -PassThru

## Add client Secret tp Azure AD App Registrations
$startDate = Get-Date
$endDate = $startDate.AddYears(2)
$aadAppKeyPwd = New-AzureADApplicationPasswordCredential -ObjectId $appObjectId -CustomKeyIdentifier "Primary" -StartDate $startDate -EndDate $endDate

## Add User to Active Directory
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $passwd
New-AzureADUser -DisplayName "New User" -PasswordProfile $PasswordProfile -UserPrincipalName "NewUser@amalandxcoutlookcom.onmicrosoft.com" -AccountEnabled $true -MailNickName "Newuser"

## Add Group tp Active Directory
New-AzureADGroup -DisplayName "DevADGroup" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"

Import-Module Az.Resources # Imports the PSADPasswordCredential object
$credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password=$passwd}
$sp = New-AzAdServicePrincipal -DisplayName ServicePrincipalName -PasswordCredential $credentials
