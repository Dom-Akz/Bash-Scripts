# Run PowerShell as Administrator

Write-Host "Disabling external physical ports..."

# Disable USB controllers
Get-PnpDevice -Class USB -Status OK | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false
}

# Disable USB hubs
Get-PnpDevice | Where-Object { $_.FriendlyName -match "USB Hub" } | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false
}

# Disable audio devices
Get-PnpDevice -Class AudioEndpoint -Status OK | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false
}

Get-PnpDevice -Class Sound -Status OK | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false
}

# Disable display outputs (HDMI / DisplayPort usually part of display adapter)
Get-PnpDevice -Class Display -Status OK | ForEach-Object {
    Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false
}

Write-Host "Ports disabled."
