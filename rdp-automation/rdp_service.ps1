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
    Write-Host "Checking RDP Service on $Server ..."

    try {
        # Get the RDP service status using WMI with credentials
        $Service = Get-WmiObject -Class Win32_Service -Filter "Name='TermService'" -ComputerName $Server -Credential $Creds -ErrorAction Stop

        # Save service status
        $Status = $Service.State
        Write-Host "$Server RDP Service Status: $Status"

        # Store results
        $Results += [PSCustomObject]@{
            Server          = $Server
            RDP_Service     = $Status
            Status          = "Success"
        }
    } catch {
        Write-Host "Failed to get RDP service status for $Server - $_"
        $Results += [PSCustomObject]@{
            Server          = $Server
            RDP_Service     = "N/A"
            Status          = "Failed"
        }
    }
}

# Export results to CSV
$Results | Export-Csv -Path "C:\My_Tasks\Automation\RDP_Service_Report.csv" -NoTypeInformation

Write-Host "Report saved to C:\My_Tasks\Automation\RDP_Service_Report.csv"
