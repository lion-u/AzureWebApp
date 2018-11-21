# Replace the following URL with a public GitHub repo URL
$gitrepo="https://github.com/Azure-Samples/app-service-web-dotnet-get-started.git"
$myID = "lz"
$type = "WebApp"
$env1 = "TST"
$resourceGroup = $myID + 'RG' + $type + $env1
$location = "West Europe"
$waname1 = $myID + $env1 + 'WA1'
$waname2 = $myID + $env1 + 'WA2'

# ########################################################
# Connect-AzureRmAccount

# Create a resource group.
New-AzureRmResourceGroup -Name $resourceGroup -Location $location

# Create an App Service plan in Free tier.
New-AzureRmAppServicePlan -Name $waname1 -Location $location -ResourceGroupName $resourceGroup -Tier Free
New-AzureRmAppServicePlan -Name $waname2 -Location $location -ResourceGroupName $resourceGroup -Tier Free

# Create a web app.
New-AzureRmWebApp -Name $waname1 -Location $location -AppServicePlan $waname1 -ResourceGroupName $resourceGroup
New-AzureRmWebApp -Name $waname2 -Location $location -AppServicePlan $waname2 -ResourceGroupName $resourceGroup

# Configure GitHub deployment from your GitHub repo and deploy once.
# $PropertiesObject = @{
#    repoUrl = "$gitrepo";
#    branch = "master";
#    isManualIntegration = "true";
# }
# Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName myResourceGroup -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $webappname/web -ApiVersion 2015-08-01 -Force


# Remove-AzureRmResourceGroup -Name $resourceGroup -Force