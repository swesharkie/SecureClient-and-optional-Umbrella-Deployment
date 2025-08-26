## Set variable to true to enable installation and setup of Umbrella with Secure Client, options are $true or $false
$umbrella_installation = $true
## If Umbrella installation is desired, set the below variables to their respective values as provided by Umbrella dashboard orginfo.json download.
$organizationId = "value"
$fingerprint = "value"
$userId = "value"

## Download Windows package for SecureClient installation, extract cisco-secure-client-win-x.x.x-core-vpn-predeploy-k9.msi and upload to an location accessible from clients, for instance an MDM solution. Insert link below.
$secure_client_link = "link_to_secure_client_msi_package"

## For Umbrella installation, also extract cisco-secure-client-win-x.x.x-umbrella-predeploy-k9.msi and do the same procedure as above.
$umbrella_link = "link_to_umbrella_msi_package"

## Don't forget to check the vpn_profile at the end of this script, it's set up with reasonable defaults but no auto-fill for connection.
## With everything filled in as desired, deploy this script via select MDM or group-policy. If selectable have the script run under user-context for reliable installation and future auto-upgrade.
## Will require reboot to start all processes if Umbrella is installed.
## May require user privilige escalation depending on the enviroment and deployment scenario

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) 
{
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit 
}  
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$secure_client_link`" /qn"
if ( $umbrella_installation )
{
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$umbrella_link`" /qn"
$org_file = "C:\\ProgramData\\Cisco\\Cisco Secure Client\\Umbrella\\OrgInfo.json"
$data=@"  
{  
    "organizationId" : "$organizationId",  
    "fingerprint" : "$fingerprint",  
    "userId" : "$userId"  
}  
"@

if (-not(Test-Path -Path $org_file))
{
  $data > $org_file
}
}

$vpn_profile = "C:\\ProgramData\\Cisco\\Cisco Secure Client\\VPN\\Profile\\vpn_profile.xml"
$data2=@"
<?xml version="1.0" encoding="UTF-8"?>
<AnyConnectProfile xmlns="http://schemas.xmlsoap.org/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.xmlsoap.org/encoding/ AnyConnectProfile.xsd">
	<ClientInitialization>
		<UseStartBeforeLogon UserControllable="true">true</UseStartBeforeLogon>
		<AutomaticCertSelection UserControllable="false">true</AutomaticCertSelection>
		<ShowPreConnectMessage>false</ShowPreConnectMessage>
		<CertificateStore>All</CertificateStore>
		<CertificateStoreMac>All</CertificateStoreMac>
		<CertificateStoreLinux>All</CertificateStoreLinux>
		<CertificateStoreOverride>false</CertificateStoreOverride>
		<ProxySettings>Native</ProxySettings>
		<AllowLocalProxyConnections>true</AllowLocalProxyConnections>
		<AuthenticationTimeout>30</AuthenticationTimeout>
		<AutoConnectOnStart UserControllable="true">false</AutoConnectOnStart>
		<MinimizeOnConnect UserControllable="true">true</MinimizeOnConnect>
		<LocalLanAccess UserControllable="true">true</LocalLanAccess>
		<DisableCaptivePortalDetection UserControllable="true">false</DisableCaptivePortalDetection>
		<ClearSmartcardPin UserControllable="false">true</ClearSmartcardPin>
		<IPProtocolSupport>IPv4,IPv6</IPProtocolSupport>
		<AutoReconnect UserControllable="false">true
			<AutoReconnectBehavior UserControllable="false">ReconnectAfterResume</AutoReconnectBehavior>
		</AutoReconnect>
		<SuspendOnConnectedStandby>false</SuspendOnConnectedStandby>
		<AutoUpdate UserControllable="false">true</AutoUpdate>
		<RSASecurIDIntegration UserControllable="false">Automatic</RSASecurIDIntegration>
		<WindowsLogonEnforcement>SingleLocalLogon</WindowsLogonEnforcement>
		<LinuxLogonEnforcement>SingleLocalLogon</LinuxLogonEnforcement>
		<WindowsVPNEstablishment>LocalUsersOnly</WindowsVPNEstablishment>
		<LinuxVPNEstablishment>LocalUsersOnly</LinuxVPNEstablishment>
		<AutomaticVPNPolicy>false</AutomaticVPNPolicy>
		<PPPExclusion UserControllable="false">Disable
			<PPPExclusionServerIP UserControllable="false"></PPPExclusionServerIP>
		</PPPExclusion>
		<EnableScripting UserControllable="false">false</EnableScripting>
		<EnableAutomaticServerSelection UserControllable="false">false
			<AutoServerSelectionImprovement>20</AutoServerSelectionImprovement>
			<AutoServerSelectionSuspendTime>4</AutoServerSelectionSuspendTime>
		</EnableAutomaticServerSelection>
		<RetainVpnOnLogoff>false
		</RetainVpnOnLogoff>
		<CaptivePortalRemediationBrowserFailover>false</CaptivePortalRemediationBrowserFailover>
		<AllowManualHostInput>true</AllowManualHostInput>
	</ClientInitialization>
	<ServerList>
		<HostEntry>
			<HostName></HostName>
			<HostAddress></HostAddress>
		</HostEntry>
	</ServerList>
</AnyConnectProfile>
"@

if (-not(Test-Path -Path $vpn_profile))  
{  
	$data2 > $vpn_profile 
}
