# Spark Temp Files Cleanup Script
# Run this periodically during local development to free disk space

param(
    [switch]$AutoConfirm,  # Skip confirmation prompt
    [switch]$Silent        # Minimal output for automated runs
)

if (-not $Silent) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Spark Temp Files Cleanup" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

# Function to get directory size
function Get-DirectorySize {
    param([string]$Path)
    if (Test-Path $Path) {
        $size = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        return [math]::Round($size / 1MB, 2)
    }
    return 0
}

# Calculate size before cleanup
if (-not $Silent) {
    Write-Host "Calculating current usage..." -ForegroundColor Yellow
}

$tempPath = "$env:TEMP\spark-*"
$localAppDataPath = "$env:LOCALAPPDATA\Temp\spark-*"
$projectTempPath = ".\spark-temp"

# Count directories for better visibility
$tempDirCount = (Get-ChildItem -Path $env:TEMP -Filter "spark-*" -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
$localAppDataDirCount = 0
if (Test-Path "$env:LOCALAPPDATA\Temp") {
    $localAppDataDirCount = (Get-ChildItem -Path "$env:LOCALAPPDATA\Temp" -Filter "spark-*" -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
}
$projectTempDirCount = 0
if (Test-Path $projectTempPath) {
    $projectTempDirCount = (Get-ChildItem -Path $projectTempPath -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
}

# Calculate sizes
$tempSize = 0
Get-ChildItem -Path $env:TEMP -Filter "spark-*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $tempSize += Get-DirectorySize $_.FullName
}

$localAppDataSize = 0
if (Test-Path "$env:LOCALAPPDATA\Temp") {
    Get-ChildItem -Path "$env:LOCALAPPDATA\Temp" -Filter "spark-*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $localAppDataSize += Get-DirectorySize $_.FullName
    }
}

$projectTempSize = Get-DirectorySize $projectTempPath

$totalSize = $tempSize + $localAppDataSize + $projectTempSize
$totalDirCount = $tempDirCount + $localAppDataDirCount + $projectTempDirCount

if (-not $Silent) {
    Write-Host ""
    Write-Host "Current Spark temp files usage:" -ForegroundColor Cyan
    Write-Host "  - System TEMP:        $tempSize MB ($tempDirCount directories)" -ForegroundColor Gray
    Write-Host "  - LocalAppData TEMP:  $localAppDataSize MB ($localAppDataDirCount directories)" -ForegroundColor Gray
    Write-Host "  - Project temp:       $projectTempSize MB ($projectTempDirCount directories)" -ForegroundColor Gray
    Write-Host "  - TOTAL:              $totalSize MB ($totalDirCount directories)" -ForegroundColor Yellow
    Write-Host ""
}

if ($totalDirCount -eq 0) {
    if (-not $Silent) {
        Write-Host "No Spark temp directories found. Nothing to clean." -ForegroundColor Green
    }
    exit 0
} elseif ($Silent) {
    # In silent mode, log cleanup intent with directory count and size
    if ($totalSize -gt 0) {
        Write-Host "  Cleaning $totalDirCount Spark temp directories (~$totalSize MB)..." -ForegroundColor Gray
    } else {
        Write-Host "  Cleaning $totalDirCount Spark temp directories..." -ForegroundColor Gray
    }
}

# Confirm cleanup
if (-not $AutoConfirm) {
    $confirmation = Read-Host "Do you want to clean up these files? (Y/N)"
    if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
        Write-Host "Cleanup cancelled." -ForegroundColor Yellow
        exit 0
    }
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "Cleaning up..." -ForegroundColor Yellow
}

# Clean system TEMP
$tempCleaned = 0
Get-ChildItem -Path $env:TEMP -Filter "spark-*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
        $tempCleaned++
    } catch {
        # Always show warnings, even in silent mode
        Write-Host "  Warning: Could not delete $($_.Name) (file in use)" -ForegroundColor Yellow
    }
}

# Clean LocalAppData TEMP
$localAppDataCleaned = 0
if (Test-Path "$env:LOCALAPPDATA\Temp") {
    Get-ChildItem -Path "$env:LOCALAPPDATA\Temp" -Filter "spark-*" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
            $localAppDataCleaned++
        } catch {
            Write-Host "  Warning: Could not delete $($_.Name) (file in use)" -ForegroundColor Yellow
        }
    }
}

# Clean project temp
$projectTempCleaned = 0
if (Test-Path $projectTempPath) {
    try {
        Get-ChildItem -Path $projectTempPath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
            $projectTempCleaned++
        }
    } catch {
        Write-Host "  Warning: Could not delete some project temp files (file in use)" -ForegroundColor Yellow
    }
}

if (-not $Silent) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Cleanup completed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Cleaned:" -ForegroundColor Cyan
    Write-Host "  - System TEMP:        $tempCleaned directories" -ForegroundColor Gray
    Write-Host "  - LocalAppData TEMP:  $localAppDataCleaned directories" -ForegroundColor Gray
    Write-Host "  - Project temp:       $projectTempCleaned directories" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Disk space freed: ~$totalSize MB" -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: Some files may still be locked if Spark is currently running." -ForegroundColor Yellow
    Write-Host ""
} else {
    # In silent mode, provide concise summary for troubleshooting
    $totalCleaned = $tempCleaned + $localAppDataCleaned + $projectTempCleaned
    if ($totalCleaned -gt 0) {
        Write-Host "  OK Cleaned $totalCleaned temp directories (~$totalSize MB freed)" -ForegroundColor Green
    } else {
        Write-Host "  OK No temp files to clean" -ForegroundColor Green
    }
}

