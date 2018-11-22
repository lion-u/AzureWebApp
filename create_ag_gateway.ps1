$myID = "lz"
$type = "WebApp"
$env1 = "Test"
$gitrepo="https://github.com/lion-u/StudentList_havronskyi.git"
$resourceGroup = $myID + 'RG' + $type + $env1
$location = "West Europe"
$waname1 = $myID + $env1 + 'WA1'
$waname2 = $myID + $env1 + 'WA2'
$wapname1 = $myID + $env1 + 'WAP1'
$wapname2 = $myID + $env1 + 'WAP2'
$appgwname = $myID +"AppGW01"
$subnetname = $resourceGroup + 'SubNet'
$subnetIP = '192.168.1.0/24'
$vnetname = $resourceGroup + 'vNet'
$vnetIP = '192.168.0.0/16'
$pipname = $myID + 'publicdns'
$fename = $myID + 'FrontEndIP' + $vmtype
$bepoolname = $myID + 'BackEndPool' + $vmtype


$webappFQDN1 = "lztstwa1.azurewebsites.net"
$webappFQDN2 = "lztstwa2.azurewebsites.net"

$webappprobe = $myID +"AppProbe"
$appGWBackendHttpSettings = $myID + "appGatewayBackendHttpSettings"
$appGatewayBackendPool = $myID + "appGatewayBackendPool"
$gatewayIP01 = $myID + "gatewayIP01"
$frontendport01 = $myID + "frontendport01"
$fipconfig01 = $myID + "fipconfig01"
$listener01 = $myID + "listener01"
$rule01 = $myID + "rule01"

# ########################################################
# Connect-AzureRmAccount

# Create a resource group.
New-AzureRmResourceGroup -Name $resourceGroup -Location $location

# Create an App Service plan in Free tier.
New-AzureRmAppServicePlan -Name $wapname1 -Location $location -ResourceGroupName $resourceGroup -Tier Free
New-AzureRmAppServicePlan -Name $wapname2 -Location $location -ResourceGroupName $resourceGroup -Tier Free

# Create a web app.
$webapps1 = New-AzureRmWebApp -Name $waname1 -Location $location -AppServicePlan $wapname1 -ResourceGroupName $resourceGroup
$webapps2 = New-AzureRmWebApp -Name $waname2 -Location $location -AppServicePlan $wapname2 -ResourceGroupName $resourceGroup

# Configure GitHub deployment from your GitHub repo and deploy once.
 $PropertiesObject = @{
    repoUrl = "$gitrepo";
    branch = "master";
    isManualIntegration = "true";
 }
Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $waname1/web -ApiVersion 2015-08-01 -Force
Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $resourceGroup -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $waname2/web -ApiVersion 2015-08-01 -Force



# Create a virtual network.
$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -AddressPrefix $subnetIP

$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -Name $vnetname `
  -AddressPrefix $vnetIP -Location $location -Subnet $subnet

# Retrieve the subnet object for use later
$subnet=$vnet.Subnets[0]

# Create a public IP address.
$publicIp = New-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Name $pipname `
  -Location $location -AllocationMethod Dynamic



# Create a new IP configuration
$gipconfig = New-AzureRmApplicationGatewayIPConfiguration -Name $gatewayIP01 -Subnet $subnet

# Create a backend pool with the hostname of the web app
$pool = New-AzureRmApplicationGatewayBackendAddressPool -Name $appGatewayBackendPool -BackendFqdns $webapps1.HostNames,$webapps2.HostNames

# Define the status codes to match for the probe
$match = New-AzureRmApplicationGatewayProbeHealthResponseMatch -StatusCode 200-399

# Create a probe with the PickHostNameFromBackendHttpSettings switch for web apps
$probeconfig = New-AzureRmApplicationGatewayProbeConfig -name $webappprobe -Protocol Http -Path / -Interval 30 -Timeout 120 -UnhealthyThreshold 3 -PickHostNameFromBackendHttpSettings -Match $match

# Define the backend http settings
$poolSetting = New-AzureRmApplicationGatewayBackendHttpSettings -Name $appGWBackendHttpSettings -Port 80 -Protocol Http -CookieBasedAffinity Disabled -RequestTimeout 120 -PickHostNameFromBackendAddress -Probe $probeconfig

# Create a new front-end port
$fp = New-AzureRmApplicationGatewayFrontendPort -Name $frontendport01  -Port 80

# Create a new front end IP configuration
$fipconfig = New-AzureRmApplicationGatewayFrontendIPConfig -Name $fipconfig01 -PublicIPAddress $publicIp

# Create a new listener using the front-end ip configuration and port created earlier
$listener = New-AzureRmApplicationGatewayHttpListener -Name $listener01 -Protocol Http -FrontendIPConfiguration $fipconfig -FrontendPort $fp

# Create a new rule
$rule = New-AzureRmApplicationGatewayRequestRoutingRule -Name $rule01 -RuleType Basic -BackendHttpSettings $poolSetting -HttpListener $listener -BackendAddressPool $pool

# Define the application gateway SKU to use
$sku = New-AzureRmApplicationGatewaySku -Name Standard_Small -Tier Standard -Capacity 2

# Create the application gateway
$appgw = New-AzureRmApplicationGateway -Name $appgwname -ResourceGroupName $resourceGroup -Location $location -BackendAddressPools $pool -BackendHttpSettingsCollection $poolSetting -Probes $probeconfig -FrontendIpConfigurations $fipconfig  -GatewayIpConfigurations $gipconfig -FrontendPorts $fp -HttpListeners $listener -RequestRoutingRules $rule -Sku $sku


#Get application gateway DNS name
Get-AzureRmPublicIpAddress -ResourceGroupName $resourceGroup -Name $pipname
# Get-AzureRmPublicIpAddress -ResourceGroupName lzRGWebAppTST -Name lzpublicdns
