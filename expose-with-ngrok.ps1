<#
expose-with-ngrok.ps1
------------------------------------------
Starts ngrok to expose local port 5000 via HTTPS and prints the public URL.

Usage:
  1. Start your app locally (node server.js or npm start)
  2. Run this script in PowerShell:
     .\expose-with-ngrok.ps1

Make sure ngrok is installed and added to PATH:
  https://ngrok.com/download
------------------------------------------
#>

Set-StrictMode -Version Latest

function Ensure-Ngrok {
    $ngrok = Get-Command ngrok -ErrorAction SilentlyContinue
    if (-not $ngrok) {
        Write-Error "❌ ngrok not found in PATH. Download from https://ngrok.com/download and add it to PATH."
        exit 1
    }
}

function Wait-ForNgrok {
    param ([int]$TimeoutSeconds = 30)

    Write-Host "⌛ Waiting for ngrok to initialize..."
    $endTime = (Get-Date).AddSeconds($TimeoutSeconds)
    $publicUrl = $null

    while ((Get-Date) -lt $endTime) {
        try {
            $tunnels = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels" -ErrorAction Stop
            $publicUrl = ($tunnels.tunnels | Where-Object { $_.proto -eq "https" }).public_url
            if ($publicUrl) { return $publicUrl }
        } catch {
            Start-Sleep -Seconds 1
        }
    }

    return $null
}

# Ensure ngrok is installed
Ensure-Ngrok

# Start ngrok tunnel
Write-Host "🚀 Starting ngrok tunnel for http://localhost:5000 ..."
$ngrokProc = Start-Process -FilePath "ngrok" -ArgumentList "http 5000" -NoNewWindow -PassThru
Start-Sleep -Seconds 2

# Wait for tunnel URL
$publicUrl = Wait-ForNgrok -TimeoutSeconds 30

if ($publicUrl) {
    Write-Host "`n✅ ngrok HTTPS tunnel ready:"
    Write-Host "🌐 $publicUrl`n"
    Write-Host "You can now test your backend online."
    Write-Host "Example API: ${publicUrl}/api/requests"
    Write-Host "`n💡 To stop ngrok, run:"
    Write-Host "   Stop-Process -Id $($ngrokProc.Id)`n"
} else {
    Write-Warning "⚠️ Could not determine ngrok tunnel URL."
    Write-Host "Visit http://127.0.0.1:4040 to view tunnel status manually."
}




