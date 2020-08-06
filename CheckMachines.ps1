#CheckMachines.ps1 List of ips loaded to ps script
# NOTE: This will work on domain only
$ipsubnet = '192.168.0.'
$computers = 1..10 | ForEach-Object -Process {$ipsubnet + $_}
# OR
#$computers = Get-Content -path '.\computers.txt'
$DateStr = (Get-Date).ToString("yyyyMMdd-HH_mm_ss")
$outputFile = ".\workstations-users-$DateStr.csv"
Write-Host "" > $outputFile

Function Get-WmiObjectCustom{            
[cmdletbinding()]            
param(            
 [string]$ComputerName = $env:ComputerName,            
 [string]$NameSpace = "root\cimv2",            
 [int]$TimeoutInseconds = 60,            
 [string]$Class            
)            

try {            
 $ConnectionOptions = new-object System.Management.ConnectionOptions            
 $EnumerationOptions = new-object System.Management.EnumerationOptions            
 $timeoutseconds = new-timespan -seconds $timeoutInSeconds            
 $EnumerationOptions.set_timeout($timeoutseconds)            
 $assembledpath = "\\{0}\{1}" -f $ComputerName, $NameSpace            
 $Scope = new-object System.Management.ManagementScope $assembledpath, $ConnectionOptions            
 $Scope.Connect()            
 $querystring = "SELECT * FROM {0}" -f $class            
 $query = new-object System.Management.ObjectQuery $querystring            
 $searcher = new-object System.Management.ManagementObjectSearcher            
 $searcher.set_options($EnumerationOptions)            
 $searcher.Query = $querystring            
 $searcher.Scope = $Scope            
 $result = $searcher.get()            
} catch {            
 Throw $_            
}            
return $result            
}

foreach($machine in $computers){
	$pinger = "ping -n 1 -w 1 $machine"
	$pingresult = Invoke-Expression $pinger | find "`"Lost = 0`"" 
	$machine
	$pingresult
	if($machine -ne "" -and $pingresult){
		Try	{
			$System = Get-WmiObjectCustom -Class Win32_ComputerSystem -TimeoutInseconds 2 -ComputerName $machine | Select-Object -Property UserName,Name,Model
			if($System){
				$BIOS = Get-WmiObjectCustom -Class Win32_BIOS -TimeoutInseconds 2 -ComputerName $machine | Select-Object -Property SerialNumber
				[PSCustomObject]@{
					ComputerName = $machine
					Name = $System.Name
					Model = $System.Model
					SerialNumber = $BIOS.SerialNumber
					User = $System.UserName
				} | Export-Csv -Path $outputFile -Append -NoTypeInformation
			}
		}
		Catch {
			Continue
		}
	}
}
