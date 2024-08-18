$AzContext = Get-AzContext

if (!$AzContext)
{
    Write-Host "You are not logged in to Azure. Run Connect-AzAccount before executing this script. Exiting"
    Exit 1
}

$Domain = Get-AzTenant | Select-Object -ExpandProperty "Domains"

$UserParams = @{
    AccountEnabled = $true
    DisplayName = "az104-user1"
    UserPrincipalName = "az104-user1@$($Domain)"
    Password = ConvertTo-SecureString "!QazXSw2#edC" -AsPlainText -Force
    JobTitle = "IT Lab Administrator"
    Department = "IT"
    MailNickname = "az104-user1"
}

New-AzADUser @UserParams

$DynamicGroupParams = @{
    MembershipRule = "(user.jobTitle -eq `"IT Lab Administrator`")"
    DisplayName = "IT Lab Administrators Dynamic"
    Description = "Administrators that manage the IT lab"
    MailNickname = "itlabadmins_dynamic"
}

New-AzADGroup @DynamicGroupParams

$StaticGroupParams = @{
    DisplayName = "IT Lab Administrators Static"
    Description = "Administrators that manage the IT lab"
    MailNickname = "itlabadmins_static"
}

New-AzADGroup @StaticGroupParams

$GroupID = (Get-AzADGroup -DisplayName $StaticGroupParams.DisplayName).Id
$UserID = (Get-AzADUser -DisplayName $UserParams.DisplayName).Id

$GroupMembershipParams = @{
    TargetGroupObjectId = $GroupID
    MemberObjectId = $UserID
}

Add-AzADGroupMember @GroupMembershipParams

Remove-AzADGroup -DisplayName $DynamicGroupParams.DisplayName
Remove-AzADGroup -DisplayName $StaticGroupParams.DisplayName
Remove-AzADUser -DisplayName $UserParams.DisplayName