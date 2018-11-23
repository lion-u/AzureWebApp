# variables
$myID = "lz"
$type = "WebApp"
$env1 = "Test"
$resourceGroup = $myID + 'RG' + $type + $env1
$location = "West Europe"

# Create a resource group.
New-AzureRmResourceGroup -Name $resourceGroup -Location $location