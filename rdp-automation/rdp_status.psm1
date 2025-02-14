# Define the path to the server list config file
$ServerListPath = "C:\path\to\server_list.txt"  # Update this path
$OutputFile = "C:\path\to\RDP_Validation_Report.csv"  # Update this path

# Read server names from the config file
$Servers = Get-Content $ServerListPath

# Initialize an empty array for storing results
$Results = @()

foreach ($Server in $Servers) {
    Write-Host "Checking $Server..."

    # Check Ping Status
    $PingStatus = Test-Connection -ComputerName $Server -Count 2 -Quiet

    # Check RDP Service Status
    try {
        $RDPService = Get-Service -ComputerName $Server -Name TermService -ErrorAction Stop
        $RDPServiceStatus = $RDPService.Status
    } catch {
        $RDPServiceStatus = "Unavailable"
    }

    # Check RDP Port Status (3389)
    try {
        $RDPPortStatus = Test-NetConnection -ComputerName $Server -Port 3389 -InformationLevel Quiet
    } catch {
        $RDPPortStatus = "Error"
    }

    # Get Last Reboot Time
    try {
        $LastReboot = Get-WmiObject Win32_OperatingSystem -ComputerName $Server | Select-Object -ExpandProperty LastBootUpTime
        $LastReboot = [System.Management.ManagementDateTimeConverter]::ToDateTime($LastReboot)
    } catch {
        $LastReboot = "Unavailable"
    }

    # Get Event Logs for RDP (Last 10 Events)
    try {
        $RDPErrors = Get-WinEvent -ComputerName $Server -LogName Security -MaxEvents 10 `
            | Where-Object { $_.Id -eq 4624 -or $_.Id -eq 4625 -or $_.Id -eq 4778 -or $_.Id -eq 4779 } `
            | Select-Object -ExpandProperty Message -ErrorAction Stop
        $RDPErrors = $RDPErrors -join "; "  # Convert array to string
    } catch {
        $RDPErrors = "Unavailable"
    }

    # Store results in an array
    $Results += [PSCustomObject]@{
        Server          = $Server
        PingStatus      = if ($PingStatus) { "Online" } else { "Offline" }
        RDPService      = $RDPServiceStatus
        RDPPortOpen     = if ($RDPPortStatus) { "Open" } else { "Closed" }
        LastReboot      = $LastReboot
        RDPErrors       = $RDPErrors
    }
}

# Export results to CSV
$Results | Export-Csv -Path $OutputFile -NoTypeInformation
Write-Host "RDP Validation Report saved to $OutputFile"
