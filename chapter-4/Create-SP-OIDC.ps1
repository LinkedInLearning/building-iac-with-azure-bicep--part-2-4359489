### Create-SP-OIDC.ps1 ###
# Log into Azure
# az login

# az account show

# variables
$subscriptionId = $(az account show --query id -o tsv)
$appName = "GitHub-LinkedIn-Bicep-OIDC"
$RBACRole = "Contributor"

$githubOrgName = "LinkedInLearning"
$githubRepoName = "building-iac-with-azure-bicep--part-2-4359489"
$githubBranch = "main"

# Create AAD App and Principal
$appId = $(az ad app create --display-name $appName --query appId -o tsv)
az ad sp create --id $appId

# Create federated GitHub credentials (Entity type 'Branch')
$githubBranchConfig = [PSCustomObject]@{
    name        = "GH-[$githubOrgName-$githubRepoName]-Branch-[$githubBranch]"
    issuer      = "https://token.actions.githubusercontent.com"
    subject     = "repo:" + "$githubOrgName/$githubRepoName" + ":ref:refs/heads/$githubBranch"
    description = "Federated credential linked to GitHub [$githubBranch] branch @: [$githubOrgName/$githubRepoName]"
    audiences   = @("api://AzureADTokenExchange")
}
$githubBranchConfigJson = $githubBranchConfig | ConvertTo-Json
$githubBranchConfigJson | az ad app federated-credential create --id $appId --parameters "@-"

# Create federated GitHub credentials (Entity type 'Pull Request')
$githubPRConfig = [PSCustomObject]@{
    name        = "GH-[$githubOrgName-$githubRepoName]-PR"
    issuer      = "https://token.actions.githubusercontent.com"
    subject     = "repo:" + "$githubOrgName/$githubRepoName" + ":pull_request"
    description = "Federated credential linked to GitHub Pull Requests @: [$githubOrgName/$githubRepoName]"
    audiences   = @("api://AzureADTokenExchange")
}
$githubPRConfigJson = $githubPRConfig | ConvertTo-Json
$githubPRConfigJson | az ad app federated-credential create --id $appId --parameters "@-"

# Assign RBAC permissions to Service Principal (Change as necessary)
$appId | foreach-object {
    az role assignment create `
        --role $RBACRole `
        --assignee $_ `
        --subscription $subscriptionId
}

#### Add New repo secerets:

#AZURE_CLIENT_ID: xxx (echo $appId)
#AZURE_TENANT_ID: yyy (get from portal)
#AZURE_SUBSCRIPTION_ID: zzz (echo $subscriptionId)
