[string[]]$machines = Get-content -path '.\machines.txt' 

$DateStr = (Get-Date).ToString("yyyyMMdd-HH_mm_ss") 
$outputFile = ".\workstations-users-$DateStr.txt" 
Write-Host "" > $outputFile 

foreach($machine in $machines){ 
	$pinger = "ping -n 1 -w 1 $machine" 
	$pingresult = Invoke-Expression $pinger | find "`"Lost = 0`"" 
	$machine 
	$pingresult 
	if($machine -ne "" -and $pingresult){ 
		$comm = '$machine.trim()' 
		Invoke-Expression $comm | Tee-Object -FilePath $outputFile -Append 
		$commandToRun = "Get-WmiObject -ComputerName $machine -Class Win32_ComputerSystem | Select-Object UserName,Name,Model" 
		Invoke-Expression $commandToRun | Tee-Object -FilePath $outputFile -Append 
	} 
}
