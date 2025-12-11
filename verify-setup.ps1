# Spark/Hadoop Environment Verification Script
# Usage: .\verify-setup.ps1
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Spark ETL Environment Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
$allChecksPass = $true
# Java
Write-Host "[1/6] Java JDK" -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-String "version" | Select-Object -First 1
    if ($javaVersion -match "17") {
        Write-Host "  ✓ Java 17 detected" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Java detected but incorrect version (expected: 17)" -ForegroundColor Yellow
        $allChecksPass = $false
    }
} catch {
    Write-Host "  ✗ Java NOT detected" -ForegroundColor Red
    $allChecksPass = $false
}
Write-Host ""
# Maven
Write-Host "[2/6] Apache Maven" -ForegroundColor Yellow
try {
    $mavenVersion = mvn -version 2>&1 | Select-String "Apache Maven" | Select-Object -First 1
    if ($mavenVersion) {
        Write-Host "  ✓ Maven detected" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Maven NOT detected" -ForegroundColor Red
    $allChecksPass = $false
}
Write-Host ""
# Spark
Write-Host "[3/6] Apache Spark" -ForegroundColor Yellow
try {
    $sparkVersion = spark-submit --version 2>&1 | Select-String "version 3.4" | Select-Object -First 1
    if ($sparkVersion) {
        Write-Host "  ✓ Spark 3.4.x detected" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Spark detected but incorrect version" -ForegroundColor Yellow
        $allChecksPass = $false
    }
} catch {
    Write-Host "  ✗ Spark NOT detected (spark-submit not found)" -ForegroundColor Red
    $allChecksPass = $false
}
Write-Host ""
# HADOOP_HOME
Write-Host "[4/6] HADOOP_HOME" -ForegroundColor Yellow
if ($env:HADOOP_HOME) {
    Write-Host "  ✓ HADOOP_HOME defined: $env:HADOOP_HOME" -ForegroundColor Green
    if (-not (Test-Path $env:HADOOP_HOME)) {
        Write-Host "  ✗ Directory NOT FOUND" -ForegroundColor Red
        $allChecksPass = $false
    }
} else {
    Write-Host "  ✗ HADOOP_HOME NOT DEFINED" -ForegroundColor Red
    Write-Host "  Action: Restart your terminal/IDE" -ForegroundColor Yellow
    $allChecksPass = $false
}
Write-Host ""
# Winutils and hadoop.dll
Write-Host "[5/6] Native Hadoop Libraries" -ForegroundColor Yellow
if ($env:HADOOP_HOME) {
    $winutilsPath = "$env:HADOOP_HOME\bin\winutils.exe"
    if (Test-Path $winutilsPath) {
        Write-Host "  ✓ winutils.exe found" -ForegroundColor Green
    } else {
        Write-Host "  ✗ winutils.exe MISSING" -ForegroundColor Red
        $allChecksPass = $false
    }
    $hadoopDllPath = "$env:HADOOP_HOME\bin\hadoop.dll"
    if (Test-Path $hadoopDllPath) {
        Write-Host "  ✓ hadoop.dll found" -ForegroundColor Green
    } else {
        Write-Host "  ✗ hadoop.dll MISSING" -ForegroundColor Red
        $allChecksPass = $false
    }
}
Write-Host ""
# Compiled project
Write-Host "[6/6] Compiled Project" -ForegroundColor Yellow
$uberJarPath = "target\scala-spark-etl-1.0-SNAPSHOT-uber.jar"
if (Test-Path $uberJarPath) {
    $jarSize = [math]::Round((Get-Item $uberJarPath).Length / 1MB, 2)
    Write-Host "  ✓ Uber JAR found ($jarSize MB)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Uber JAR NOT FOUND" -ForegroundColor Red
    Write-Host "  Action: mvn clean package" -ForegroundColor Yellow
    $allChecksPass = $false
}
if (Test-Path "data\input") {
    $csvCount = (Get-ChildItem "data\input" -Filter "*.csv" -File -ErrorAction SilentlyContinue).Count
    if ($csvCount -gt 0) {
        Write-Host "  ✓ Input data present ($csvCount CSV files)" -ForegroundColor Green
    } else {
        Write-Host "  INFO No CSV files in data/input" -ForegroundColor Gray
    }
}
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
if ($allChecksPass) {
    Write-Host "SUCCESS - ALL CHECKS PASSED" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your environment is correctly configured!" -ForegroundColor Green
    Write-Host "You can run: .\run-spark-etl.ps1" -ForegroundColor Cyan
} else {
    Write-Host "FAILED - SOME CHECKS DID NOT PASS" -ForegroundColor Red
    Write-Host ""
    Write-Host "Consult:" -ForegroundColor Yellow
    Write-Host "  - WINDOWS-SETUP.md (installation guide)" -ForegroundColor White
    Write-Host "  - FAQ.md (troubleshooting)" -ForegroundColor White
    exit 1
}
Write-Host ""
