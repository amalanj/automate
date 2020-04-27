$rg = "learn"
$newuser = "admin@amalandxcoutlookcom.onmicrosoft.com"
$newuserid = "nandhini"
$readeraccess = "reader"
$owneraccess = "owner"
$learnkv = "learn-dev-kv"
$appObjectId = "6505f383-3154-4e1e-bc23-681d9e1f4bfd"
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile


## Resource Group access to users based on Role
New-AzureRmRoleAssignment -ResourceGroupName $rg -SignInName $newuser -RoleDefinitionName $owneraccess

## Keyvault access to users based on Role
New-AzureRmRoleAssignment -SignInName $newuser -RoleDefinitionName $readeraccess -Scope "/subscriptions/f50f21e7-d78c-411f-a537-3b4e35150985/resourceGroups/learn/providers/Microsoft.KeyVault/vaults/learn-dev-kv"

## Adding new secret to Keyvault
$Secret = ConvertTo-SecureString -String 'm{9JsStGE#phyfrn' -AsPlainText -Force
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
$PasswordProfile.Password = "P@$$^oRd"
New-AzureADUser -DisplayName "New User" -PasswordProfile $PasswordProfile -UserPrincipalName "NewUser@amalandxcoutlookcom.onmicrosoft.com" -AccountEnabled $true -MailNickName "Newuser"

## Add Group tp Active Directory
New-AzureADGroup -DisplayName "DevADGroup" -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"

Import-Module Az.Resources # Imports the PSADPasswordCredential object
$credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password="P@$$^oRd"}
$sp = New-AzAdServicePrincipal -DisplayName ServicePrincipalName -PasswordCredential $credentials