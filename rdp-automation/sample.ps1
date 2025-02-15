try {
    # Run commands on the remote server using Invoke-Command
    $remoteResult = Invoke-Command -ComputerName $Server -Credential $Credential -ScriptBlock {
        # Get the last boot time
        $os = Get-WmiObject -Class Win32_OperatingSystem
        $lastBootTime = $os.LastBootUpTime

        # Get the RDP Service Status
        $rdpService = Get-Service -Name TermService -ErrorAction SilentlyContinue
        $rdpStatus = if ($rdpService) { $rdpService.Status } else { "Service Not Found" }

        # Return results as an object
        [PSCustomObject]@{
            LastBootTime = $lastBootTime
            RDPStatus    = $rdpStatus
        }
    } -ErrorAction Stop

    # Store the values from the remote execution
    $lastBootTime = $remoteResult.LastBootTime
    $rdpStatus = $remoteResult.RDPStatus
} catch {
    $lastBootTime = "Error"
    $rdpStatus = "Error"
}

# Display results
Write-Host "Last Boot Time: $lastBootTime"
Write-Host "RDP Service Status: $rdpStatus"
