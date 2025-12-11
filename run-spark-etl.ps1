# Spark ETL Application Runner
# Usage: .\run-spark-etl.ps1
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Spark ETL - Application Execution" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
# Configure environment variables
$env:HADOOP_HOME = "C:\dev\dev-tools\hadoop-3.3.5"
Write-Host "OK HADOOP_HOME configured: $env:HADOOP_HOME" -ForegroundColor Green
# Check winutils.exe
$winutilsPath = "$env:HADOOP_HOME\bin\winutils.exe"
if (Test-Path $winutilsPath) {
    Write-Host "OK winutils.exe found" -ForegroundColor Green
} else {
    Write-Host "ERROR: winutils.exe not found in $env:HADOOP_HOME\bin" -ForegroundColor Red
    Write-Host "  Download from: https://github.com/cdarlint/winutils" -ForegroundColor Yellow
    exit 1
}
# Check uber JAR
$uberJarPath = "target\scala-spark-etl-1.0-SNAPSHOT-uber.jar"
if (-not (Test-Path $uberJarPath)) {
    Write-Host "ERROR: Uber JAR not found. Compiling..." -ForegroundColor Yellow
    Write-Host ""
    mvn clean package -DskipTests
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR during compilation" -ForegroundColor Red
        exit 1
    }
}
Write-Host "OK Uber JAR found" -ForegroundColor Green
Write-Host ""
# Check input data
$inputPath = "data\input"
if (-not (Test-Path $inputPath)) {
    Write-Host "data/input directory not found. Creating..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $inputPath | Out-Null
    # Create sample CSV file
    "id,name,age,city" | Out-File -FilePath "$inputPath\sample.csv" -Encoding utf8
    "1,John Doe,30,New York" | Out-File -FilePath "$inputPath\sample.csv" -Encoding utf8 -Append
    "2,Jane Smith,25,Los Angeles" | Out-File -FilePath "$inputPath\sample.csv" -Encoding utf8 -Append
    "3,Bob Johnson,35,Chicago" | Out-File -FilePath "$inputPath\sample.csv" -Encoding utf8 -Append
    "4,Alice Williams,28,Houston" | Out-File -FilePath "$inputPath\sample.csv" -Encoding utf8 -Append
    "5,Charlie Brown,32,Phoenix" | Out-File -FilePath "$inputPath\sample.csv" -Encoding utf8 -Append
    Write-Host "OK sample.csv created in data/input" -ForegroundColor Green
}
# Count CSV files
$csvFiles = Get-ChildItem -Path $inputPath -Filter "*.csv" -File -ErrorAction SilentlyContinue
Write-Host "OK CSV files found: $($csvFiles.Count)" -ForegroundColor Green
Write-Host ""
# Add Hadoop bin to PATH for native library access
$env:PATH = "$env:HADOOP_HOME\bin;$env:PATH"
Write-Host "OK PATH updated with Hadoop bin" -ForegroundColor Green
Write-Host ""
# Setup and clean Spark temp directory
$sparkTempDir = "spark-temp"
Write-Host "Preparing Spark temp directory..." -ForegroundColor Yellow
# Run cleanup script if it exists
if (Test-Path ".\cleanup-temp.ps1") {
    # Run cleanup non-interactively (auto-confirm)
    & .\cleanup-temp.ps1 -AutoConfirm -Silent
} else {
    # Fallback: simple cleanup if script not found
    if (Test-Path $sparkTempDir) {
        Remove-Item -Path "$sparkTempDir\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}
# Ensure temp directory exists
if (-not (Test-Path $sparkTempDir)) {
    New-Item -ItemType Directory -Force -Path $sparkTempDir | Out-Null
}
Write-Host "OK Spark temp directory ready" -ForegroundColor Green
Write-Host ""
# Run spark-submit
$sparkCommand = "spark-submit --class com.company.etl.spark.Main --master local[*] --conf spark.local.dir=$sparkTempDir $uberJarPath"
Write-Host "Executing: $sparkCommand" -ForegroundColor Cyan
Invoke-Expression $sparkCommand
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Execution error" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host ""
Write-Host "Spark job finished successfully" -ForegroundColor Green
