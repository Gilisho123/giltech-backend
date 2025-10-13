<#
run-local.ps1
Automates local setup: copy env, docker compose up, run migration, create admin via API.
Usage: Open PowerShell in project root and run: .\run-local.ps1
#>

Set-StrictMode -Version Latest

$envFile = ".env"
$envCompose = ".env.compose"

if (-not (Test-Path $envCompose)) {
    Write-Error "Missing .env.compose. Create or check the file and try again."
    exit 1
}

if (-not (Test-Path $envFile)) {
    Copy-Item $envCompose -Destination $envFile -Force
    Write-Host "Created .env from .env.compose"
} else {
    Write-Host ".env already exists; leaving it unchanged (edit manually if needed)"
}

# Prompt for ADMIN_TOOL_TOKEN (optional)
$wantAdmin = Read-Host "Do you want to create an admin user after startup? (y/N)"
$adminToken = ""
if ($wantAdmin -match '^[Yy]') {
    $adminToken = Read-Host "Enter a temporary ADMIN_TOOL_TOKEN to enable the admin creation endpoint"
    if ($adminToken) {
        $contents = Get-Content $envFile -Raw
        if ($contents -match '(?m)^\s*ADMIN_TOOL_TOKEN=') {
            $contents = $contents -replace '(?m)^\s*ADMIN_TOOL_TOKEN=.*', "ADMIN_TOOL_TOKEN=$adminToken"
        } else {
            $contents = $contents.TrimEnd() + "`nADMIN_TOOL_TOKEN=$adminToken`n"
        }
        $contents | Set-Content $envFile -Force
        Write-Host "Wrote ADMIN_TOOL_TOKEN to .env"
    } else {
        Write-Host "No token entered; admin creation will be skipped."
    }
}

# Start services
Write-Host "Starting Docker Compose services... (this may take a minute)"
$start = Start-Process -FilePath "docker" -ArgumentList "compose --env-file .env up -d --build" -NoNewWindow -PassThru -Wait
if ($start.ExitCode -ne 0) {
    Write-Error "docker compose failed to start. Make sure Docker is running and try again."
    exit $start.ExitCode
}

# Wait for the app to respond on port 5000
Write-Host "Waiting for the app to respond at http://localhost:5000 ..."
$maxAttempts = 60
$attempt = 0
$ok = $false
while ($attempt -lt $maxAttempts) {
    try {
        $r = Invoke-WebRequest -Uri 'http://localhost:5000' -UseBasicParsing -Method GET -TimeoutSec 5
        if ($r.StatusCode -eq 200 -or $r.StatusCode -eq 302 -or $r.StatusCode -eq 404) {
            Write-Host "App responded (status $($r.StatusCode))."
            $ok = $true
            break
        }
    } catch {
        # ignore
    }
    Start-Sleep -Seconds 2
    $attempt++
    Write-Host "Waiting for app... attempt $attempt/$maxAttempts"
}

if (-not $ok) {
    Write-Error "App did not respond on http://localhost:5000 within the timeout. Check 'docker ps' and 'docker logs' for details."
    exit 1
}

# Find app container name (compose service likely called 'giltech-backend_app_1' or similar)
Write-Host "Locating app container..."
$container = docker ps --format "{{.Names}}" | Select-String -Pattern "app|giltech|backend" -Quiet | Out-Null
# The above attempts to detect; fallback to first container
$names = docker ps --format "{{.Names}}" | Out-String
$found = $null
$names -split "`n" | ForEach-Object {
    $n = $_.Trim()
    if ($n -and ($n -match 'app' -or $n -match 'giltech' -or $n -match 'backend')) { $found = $n; return }
}
if (-not $found) {
    $found = ($names -split "`n" | Where-Object { $_.Trim() } | Select-Object -First 1).Trim()
}

if (-not $found) {
    Write-Warning "Could not automatically determine the app container name. You may need to run the migration manually."
} else {
    Write-Host "Found container: $found"
    Write-Host "Running DB migration inside container..."
    docker exec -it $found node scripts/run_create_users.js
}

# Create admin via HTTP if requested
if ($adminToken) {
    $email = Read-Host "Admin email to create (default: admin@giltech.local)"
    if (-not $email) { $email = 'admin@giltech.local' }
    Write-Host "Enter admin password (input will be hidden)"
    $securePwd = Read-Host -AsSecureString "Password"
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd)
    $plainPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

    $body = @{ token = $adminToken; email = $email; password = $plainPwd } | ConvertTo-Json
    Write-Host "Creating admin via API..."
    try {
        $resp = Invoke-RestMethod -Uri 'http://localhost:5000/api/admin-tools/create-admin' -Method Post -Body $body -ContentType 'application/json'
        Write-Host "Admin creation response:`n" (ConvertTo-Json $resp -Depth 5)
        Write-Host "IMPORTANT: Remove ADMIN_TOOL_TOKEN from .env after this step to disable the endpoint."
    } catch {
        Write-Error "Failed to create admin via API: $_"
    }
}

Write-Host "All done. Visit http://localhost:5000 or https://www.giltechonlinecyber.co.ke once DNS is configured."
