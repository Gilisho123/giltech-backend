<#
run-local.ps1
Automates local setup for Giltech Online Cyber backend.
Usage: Open PowerShell in the project root and run:
  .\run-local.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Step 1: Prepare environment
$envFile = ".env"
$envCompose = ".env.compose"

Write-Host "=== Giltech Backend Setup ==="

if (-not (Test-Path $envCompose)) {
    Write-Error "❌ Missing .env.compose. Please create it or pull from repository."
    exit 1
}

if (-not (Test-Path $envFile)) {
    Copy-Item $envCompose -Destination $envFile -Force
    Write-Host "✅ Created .env from .env.compose"
} else {
    Write-Host "ℹ️ .env already exists; skipping copy."
}

# Step 2: Optional admin setup
$wantAdmin = Read-Host "Do you want to create an admin user after startup? (y/N)"
$adminToken = ""

if ($wantAdmin -match '^[Yy]') {
    $adminToken = Read-Host "Enter a temporary ADMIN_TOOL_TOKEN to enable admin endpoint"
    if ($adminToken) {
        $contents = Get-Content $envFile -Raw
        if ($contents -match '(?m)^\s*ADMIN_TOOL_TOKEN=') {
            $contents = $contents -replace '(?m)^\s*ADMIN_TOOL_TOKEN=.*', "ADMIN_TOOL_TOKEN=$adminToken"
        } else {
            $contents = $contents.TrimEnd() + "`nADMIN_TOOL_TOKEN=$adminToken`n"
        }
        $contents | Set-Content $envFile -Force
        Write-Host "🔐 Added ADMIN_TOOL_TOKEN to .env"
    } else {
        Write-Host "Skipping admin creation."
    }
}

# Step 3: Start Docker Compose
Write-Host "🚀 Starting backend services (Docker Compose)..."
docker compose --env-file .env up -d --build

if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Docker Compose failed to start. Ensure Docker is running."
    exit $LASTEXITCODE
}

# Step 4: Wait for API readiness
Write-Host "⌛ Waiting for backend (http://localhost:5000)..."
$maxAttempts = 60
for ($i = 1; $i -le $maxAttempts; $i++) {
    try {
        $r = Invoke-WebRequest -Uri 'http://localhost:5000' -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -in 200, 302, 404) {
            Write-Host "✅ Backend is live (HTTP $($r.StatusCode))"
            break
        }
    } catch {}
    Start-Sleep -Seconds 2
    Write-Host "Attempt $i/$maxAttempts..."
    if ($i -eq $maxAttempts) {
        Write-Error "❌ Backend did not respond. Check 'docker ps' and 'docker logs'."
        exit 1
    }
}

# Step 5: Run DB migration
Write-Host "⚙️ Running DB migration script inside container..."
$container = docker ps --format "{{.Names}}" | Where-Object { $_ -match "giltech|backend|app" } | Select-Object -First 1

if (-not $container) {
    Write-Warning "Could not find backend container automatically."
} else {
    docker exec -it $container node scripts/run_create_users.js
}

# Step 6: Optional admin user creation
if ($adminToken) {
    $email = Read-Host "Admin email (default: admin@giltech.local)"
    if (-not $email) { $email = "admin@giltech.local" }

    Write-Host "Enter admin password (hidden input)"
    $securePwd = Read-Host -AsSecureString "Password"
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd)
    $plainPwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

    $body = @{ token = $adminToken; email = $email; password = $plainPwd } | ConvertTo-Json
    Write-Host "📤 Sending admin creation request..."
    try {
        $resp = Invoke-RestMethod -Uri 'http://localhost:5000/api/admin-tools/create-admin' -Method Post -Body $body -ContentType 'application/json'
        Write-Host "✅ Admin created successfully!"
        $resp | ConvertTo-Json -Depth 5
        Write-Host "⚠️ IMPORTANT: Remove ADMIN_TOOL_TOKEN from .env after setup."
    } catch {
        Write-Error "❌ Failed to create admin via API: $_"
    }
}

Write-Host "🎉 All setup complete! Visit http://localhost:5000 or your Render deployment URL."
