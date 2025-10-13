<#
expose-with-ngrok.ps1
Starts ngrok to expose local port 5000 via HTTPS and prints the public URL.

Usage:
1. Ensure your app is running locally on port 5000 (use run-local.ps1 or `node server.js`).
2. Install ngrok and make sure `ngrok` is on your PATH: https://ngrok.com/download
3. Run this script in PowerShell:
   .\expose-with-ngrok.ps1

The script will start ngrok, wait for the tunnel to be available, then print the HTTPS URL.
#>

Set-StrictMode -Version Latest

function Ensure-Ngrok {
    $ngrok = Get-Command ngrok -ErrorAction SilentlyContinue
    if (-not $ngrok) {
        Write-Error "ngrok not found in PATH. Download from https://ngrok.com/download and add to PATH."
        exit 1
    }
}

Ensure-Ngrok

# Start ngrok
Write-Host "Starting ngrok tunnel for http://localhost:5000 ..."
$ngrokProc = Start-Process -FilePath "ngrok" -ArgumentList "http 5000" -NoNewWindow -PassThru
Start-Sleep -Seconds 1

# Wait for the local ngrok API to respond
$max = 30
$i = 0
$publicUrl = $null
while ($i -lt $max) {
    try {
        $tunnels = Invoke-RestMethod -Uri http://127.0.0.1:4040/api/tunnels -Method GET -TimeoutSec 2
        if ($tunnels.tunnels) {
            foreach ($t in $tunnels.tunnels) {
                if ($t.public_url -and $t.proto -eq 'https') { $publicUrl = $t.public_url; break }
            }
            if ($publicUrl) { break }
        }
    } catch {
        # ignore
    }
    Start-Sleep -Seconds 1
    $i++
}

if ($publicUrl) {
    Write-Host "ngrok HTTPS tunnel ready: $publicUrl"
    Write-Host "You can open it in your browser now."
    Write-Host "NOTE: If you want to use your custom domain with ngrok, follow ngrok docs about reserved domains or CNAME mapping (paid feature)."
} else {
    Write-Warning "Could not determine ngrok tunnel URL. ngrok process ID: $($ngrokProc.Id)"
    Write-Host "You can open http://127.0.0.1:4040 to view tunnels and their public URLs."
}

Write-Host "To stop ngrok, terminate the ngrok process or press Ctrl+C in the ngrok window."
