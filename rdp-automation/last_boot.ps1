# Prompt for user credentials
$Creds = Get-Credential

# Define the list of servers
$ServerListPath = "C:\My_Tasks\Automation\server_list.txt"

# Check if the file exists
if (-Not (Test-Path $ServerListPath)) {
    Write-Host "Error: Server list file not found at $ServerListPath"
    exit
}

# Read the server list
$Servers = Get-Content $ServerListPath

# Create an empty array for results
$Results = @()

# Loop through each server
foreach ($Server in $Servers) {
    Write-Host "Checking $Server ..."

    try {
        # Get last boot time using WMI with credentials
        $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Server -Credential $Creds -ErrorAction Stop
        $LastBoot = $OS.LastBootUpTime

        # Convert to human-readable format
        $LastRebootTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($LastBoot)

        Write-Host "$Server last rebooted on: $LastRebootTime"

        # Save results
        $Results += [PSCustomObject]@{
            Server          = $Server
            LastRebootTime  = $LastRebootTime
            Status          = "Success"
        }
    } catch {
        Write-Host "Failed to get info for $Server - $_"
        $Results += [PSCustomObject]@{
            Server          = $Server
            LastRebootTime  = "N/A"
            Status          = "Failed"
        }
    }
}

# Export results to CSV
$Results | Export-Csv -Path "C:\My_Tasks\Automation\LastReboot_Report.csv" -NoTypeInformation

Write-Host "Report saved to C:\My_Tasks\Automation\LastReboot_Report.csv"
