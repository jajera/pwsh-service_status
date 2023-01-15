$ErrorActionPreference = "Continue"; 

$reportPath = ".\";  
$reportName = "ServiceStatus.html"; 
$hcReport = $reportPath + $reportName 

$redColor = "#FF0000" 
$orangeColor = "#FBB917" 
$whiteColor = "#00FF00"

$serviceList = Get-Content .\servicelist.json | Out-String | ConvertFrom-Json

If (Test-Path $hcReport) { Remove-Item $hcReport } 
 
$titleDate = (Get-Date ).ToString('yyyy/MM/dd') + " - " + (Get-Date).DayOfWeek
$header = " 
	<html> 
	<head> 
	<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'> 
	<title>Service Status</title> 
	<STYLE TYPE='text/css'> 
	<!-- 
	td { 
	font-family: Tahoma; 
	font-size: 11px;
    color: #d2f5ff;
	border-top: 0px solid #999999; 
	border-right: 0px solid #999999; 
	border-bottom: 0px solid #999999; 
	border-left: 0px solid #999999; 
	padding-top: 5px; 
	padding-right: 1px; 
	padding-bottom: 5px; 
	padding-left: 5px; 
	} 
	body { 
	margin-left: 5px; 
	margin-top: 5px; 
	margin-right: 0px; 
	margin-bottom: 10px; 
	table { 
	border: thin solid #000000;
    border-collapse: collapse;
	} 
	--> 
	</style> 
	</head> 
	<body> 
	<table width='100%'> 
	<tr bgcolor='#36304a'> 
	<td colspan='7' height='25' align='center'> 
	<font face='tahoma' color='#d2f5ff' size='4'><strong>Service Status - $titledate</strong></font> 
	</td> 
	</tr> 
    </table>
    <br/> 
	" 
Add-Content $hcReport $header 

$tableHeader = " 
    <br/>
    <table width='100%'><tbody> 
    <tr bgcolor='#36304a'> 
	<td colspan='4' height='20' align='center'> 
	<font face='tahoma' color='#d2f5ff' size='2'><strong>SERVICES</strong></font> 
	</td> 
	</tr> 
	<tr bgcolor='#36304a'> 
	<td width='10%' align='center'>Server</td> 
	<td width='15%' align='center'>Service</td> 
	<td width='10%' align='center'>Status</td> 
	<td width='15%' align='center'>Startup Type</td> 
	</tr> 
	" 
Add-Content $hcReport $tableHeader 

foreach ($server in $serviceList) {
	$computer = $server.name.toupper();
	foreach ($service in $server.services) {

		$service_info = Get-Service -ComputerName $computer -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $service.name } | Select-Object DisplayName, Status, StartType;
		$color_status_svc = $whiteColor;
		$color_startup_svc = $whiteColor;

		if ($service_info.Status -ne $service.status) { 
			$color_status_svc = $redColor
		} 
		if ($service_info.StartType -ne $service.startup) { 
			$color_startup_svc = $redColor
		} 

		$dataRow = " 
            <tr> 
            <td width='10%' bgcolor='#36304a'>$computer</td> 
            <td width='10%' bgcolor='#36304a' align='center'>$($service.name)</td> 
            <td width='10%' bgcolor=$($color_status_svc) align='center'>$($service_info.Status)</td> 
            <td width='10%' bgcolor=$($color_startup_svc) align='center'>$($service_info.StartType)</td> 
            </tr> 
    	" 
		Add-Content $hcReport $dataRow; 
	}
}

$tableDescription = " 
	</table><br><table width='20%'> 
    <table width=30%>
    <tr bgcolor='White'> 
	<td width='100%' align='center' bgcolor='#FF0000'>Critical non-compliant</td> 
    </tr>
    </table>
	" 
Add-Content $hcReport $tableDescription
