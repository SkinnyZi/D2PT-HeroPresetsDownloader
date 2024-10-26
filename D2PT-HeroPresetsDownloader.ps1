$url = "https://dota2protracker.com/downloads/meta-hero-grid"
$downloadedFileName = "dota2protracker_hero_grid_config.json"

$destination = "$PSScriptRoot\$downloadedFileName"
Invoke-WebRequest -Uri $url -OutFile $destination
Write-Output "File downloaded: $destination"

$steamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "InstallPath").InstallPath
$userdataPath = "$steamPath\userdata"

if (-Not (Test-Path -Path $userdataPath)) {
    Write-Output "userdata folder not found. Make sure Steam is installed."
    exit
}

$steamIDs = Get-ChildItem -Path $userdataPath -Directory | Select-Object -ExpandProperty Name
Write-Output "Available Steam IDs:"
$steamIDs | ForEach-Object { Write-Output "$($steamIDs.IndexOf($_) + 1). $_" }
$selection = Read-Host "Enter the number of the Steam ID from the list above"
$selectedIndex = [int]$selection - 1
if ($selectedIndex -lt 0 -or $selectedIndex -ge $steamIDs.Count) {
    Write-Output "Invalid selection. Please try again."
    exit
}
$selectedSteamID = $steamIDs[$selectedIndex]
$cfgPath = "$userdataPath\$selectedSteamID\570\remote\cfg"

if (-Not (Test-Path -Path $cfgPath)) {
    Write-Output "Dota 2 folder not found for Steam ID: $selectedSteamID"
    exit
}

$heroGridFile = "$cfgPath\hero_grid_config.json"
$backupFile = "$cfgPath\hero_grid_config_backup.json"

if (Test-Path -Path $heroGridFile) {
    Rename-Item -Path $heroGridFile -NewName "hero_grid_config_backup.json"
    Write-Output "Old hero_grid_config.json renamed to hero_grid_config_backup.json"
}

Copy-Item -Path $downloadedFileName -Destination $heroGridFile
Write-Output "New hero_grid_config.json copied to Dota 2 folder."

Remove-Item -Path $destination
Write-Output "Downloaded file deleted."

Write-Output "Done. Please start or restart Dota 2."
