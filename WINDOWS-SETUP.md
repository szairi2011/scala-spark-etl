# Windows Setup and Configuration Guide

Complete guide to configure and run the Spark ETL application on Windows.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installing Spark and Hadoop](#installing-spark-and-hadoop)
3. [Configuring Environment Variables](#configuring-environment-variables)
4. [Installing winutils.exe](#installing-winutilsexe)
5. [Verifying Installation](#verifying-installation)
6. [Running the Application](#running-the-application)
7. [Useful Commands](#useful-commands)
8. [Going Further](#going-further)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Software
- **Java JDK 17** - [Download](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
- **Maven 3.x** - [Download](https://maven.apache.org/download.cgi)
- **Apache Spark 3.4.1** - [Download](https://spark.apache.org/downloads.html)
- **Git** (optional)

### Tested and Compatible Versions
| Composant | Version | Statut |
|-----------|---------|--------|
| Java | 17 | ✅ |
| Spark | 3.4.1 | ✅ |
| Hadoop | 3.3.5 | ✅ |
| Scala | 2.12.18 | ✅ |
| Maven | 3.9+ | ✅ |

---

## Installing Spark and Hadoop

### 1. Download Spark

Download **Spark 3.4.1 pre-built for Hadoop 3** from:  
https://spark.apache.org/downloads.html

### 2. Extract Spark

Extract the archive to a simple directory, for example:
```
C:\dev\dev-tools\spark-3.4.1-bin-hadoop3\
```

### 3. Download winutils for Hadoop

Clone or download the winutils repository:
```powershell
git clone https://github.com/cdarlint/winutils.git C:\dev\dev-tools\winutils-master
```

**OR** download directly from:  
https://github.com/cdarlint/winutils

### 4. Copy Hadoop Files

Copy **all contents** from the `hadoop-3.3.5` folder to a new directory:
```powershell
# Create directory
New-Item -ItemType Directory -Force -Path "C:\dev\dev-tools\hadoop-3.3.5"

# Copy files
Copy-Item -Path "C:\dev\dev-tools\winutils-master\hadoop-3.3.5\*" -Destination "C:\dev\dev-tools\hadoop-3.3.5\" -Recurse -Force
```

**Expected final structure:**
```
C:\dev\dev-tools\
├── spark-3.4.1-bin-hadoop3\
│   └── bin\
│       └── spark-submit.cmd
└── hadoop-3.3.5\
    └── bin\
        ├── winutils.exe
        ├── hadoop.dll
        └── (other files)
```

---

## Configuring Environment Variables

### Permanent Configuration (Recommended)

Run these commands in **PowerShell as Administrator**:

```powershell
# HADOOP_HOME
[Environment]::SetEnvironmentVariable("HADOOP_HOME", "C:\dev\dev-tools\hadoop-3.3.5", "User")

# Add Spark to PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$sparkPath = "C:\dev\dev-tools\spark-3.4.1-bin-hadoop3\bin"
$hadoopPath = "C:\dev\dev-tools\hadoop-3.3.5\bin"

if ($currentPath -notlike "*$sparkPath*") {
    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$sparkPath;$hadoopPath", "User")
}

Write-Host "Environment variables configured successfully!" -ForegroundColor Green
Write-Host "IMPORTANT: Restart your terminal or IntelliJ IDEA to apply changes." -ForegroundColor Yellow
```

### Verification

**Close and reopen your terminal**, then verify:

```powershell
# Check HADOOP_HOME
echo $env:HADOOP_HOME
# Expected: C:\dev\dev-tools\hadoop-3.3.5

# Check winutils.exe
Test-Path "$env:HADOOP_HOME\bin\winutils.exe"
# Expected: True

# Check spark-submit
spark-submit --version
# Should display: version 3.4.1
```

---

## Installing winutils.exe

### Why winutils.exe?

On Windows, Hadoop requires native libraries (`winutils.exe`, `hadoop.dll`) to access the local file system. Without these files, you will get the error:

```
UnsatisfiedLinkError: 'boolean org.apache.hadoop.io.nativeio.NativeIO$Windows.access0'
```

### Compatible Versions

**IMPORTANT**: The winutils.exe version **MUST** match the Hadoop version used by Spark.

| Spark | Hadoop Bundled | winutils Version |
|-------|----------------|------------------|
| 3.4.1 | 3.3.x | **3.3.5** ✅ |
| 3.4.1 | 3.3.x | 3.0.1 ❌ |

### Installation Verification

```powershell
# Check that winutils.exe exists
dir "$env:HADOOP_HOME\bin\winutils.exe"

# Check that hadoop.dll exists
dir "$env:HADOOP_HOME\bin\hadoop.dll"
```

---

## Verifying Installation

### Automated Verification

After configuring environment variables and restarting your terminal, run the automated verification script:

```powershell
.\verify-setup.ps1
```

This script validates all requirements and displays a comprehensive checklist:
- ✅ Java 17
- ✅ Maven 3.x
- ✅ Spark 3.4.1
- ✅ HADOOP_HOME defined and valid
- ✅ winutils.exe present
- ✅ hadoop.dll present
- ✅ Project compiled (uber JAR)
- ✅ Input data available

**What the script checks:**
- Software versions (Java, Maven, Spark)
- Environment variables configuration
- Required Hadoop native files
- Project build status
- Sample data availability

If any item shows ❌, the script provides guidance on how to fix it.

---

## Running the Application

### First Execution

1. **Compile the project**:
```powershell
cd C:\dev\projects\scala-spark-etl
mvn clean package
```

2. **Create test data** (if necessary):
```powershell
# The run-spark-etl.ps1 script automatically creates a sample.csv file
# OR create it manually:
New-Item -ItemType Directory -Force -Path "data\input"

@"
id,name,age,city
1,John Doe,30,New York
2,Jane Smith,25,Los Angeles
3,Bob Johnson,35,Chicago
"@ | Out-File -FilePath "data\input\sample.csv" -Encoding UTF8
```

3. **Run the application**:

**Option A - Automated script** (recommended):
```powershell
.\run-spark-etl.ps1
```

**Option B - Manual command**:
```powershell
# IMPORTANT: Add Hadoop bin to PATH first
$env:PATH = "$env:HADOOP_HOME\bin;$env:PATH"
spark-submit --class com.company.etl.spark.Main --master local[*] target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

### Success Logs

A successful execution displays:
```
INFO InMemoryFileIndex: It took X ms to list leaf files for 1 paths
INFO DAGScheduler: Job 0 finished: csv at DemoJob.scala:13, took X s
INFO FileFormatWriter: Write Job ... committed
INFO SparkContext: Successfully stopped SparkContext
```

---

## Troubleshooting

If you encounter any issues during installation or execution, please refer to:

**📖 [FAQ.md](FAQ.md) - Frequently Asked Questions and Troubleshooting**

The FAQ covers:
- `UnsatisfiedLinkError` solutions
- `spark-submit` not recognized
- Maven BUILD FAILURE
- Missing input files
- Environment verification
- And more common issues

**To verify your setup**, use the automated verification script described in the [Verifying Installation](#verifying-installation) section above.

---

## 📝 Useful Commands

### Compilation
```powershell
# Complete compilation
mvn clean package

# Compilation without tests
mvn clean package -DskipTests

# Clean only
mvn clean
```

### Execution
```powershell
# Via script (recommended)
.\run-spark-etl.ps1

# Via direct spark-submit (IMPORTANT: add Hadoop bin to PATH first)
$env:PATH = "$env:HADOOP_HOME\bin;$env:PATH"
spark-submit --class com.company.etl.spark.Main --master local[*] target\scala-spark-etl-1.0-SNAPSHOT-uber.jar

# With detailed logs
$env:PATH = "$env:HADOOP_HOME\bin;$env:PATH"
spark-submit --class com.company.etl.spark.Main --master local[*] --conf spark.eventLog.enabled=true target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

### Tests
```powershell
# Run all tests
mvn test

# Specific test
mvn test -Dtest=SampleTest
```

---

## 🎓 Going Further

### Customize the Application

1. **Modify transformations**:  
   Edit `src/main/scala/com/company/etl/spark/jobs/Transformations.scala`

2. **Add a new job**:  
   Create a new file in `src/main/scala/com/company/etl/spark/jobs/`

3. **Configure paths**:  
   Edit `src/main/resources/application.conf`

### Advanced Spark Configuration

```powershell
# IMPORTANT: Add Hadoop bin to PATH first
$env:PATH = "$env:HADOOP_HOME\bin;$env:PATH"

# PowerShell - use backticks for line continuation
spark-submit `
  --class com.company.etl.spark.Main `
  --master local[4] `
  --driver-memory 2g `
  --executor-memory 2g `
  --conf spark.sql.shuffle.partitions=200 `
  target\scala-spark-etl-1.0-SNAPSHOT-uber.jar

# OR as a single line
spark-submit --class com.company.etl.spark.Main --master local[4] --driver-memory 2g --executor-memory 2g --conf spark.sql.shuffle.partitions=200 target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

---

## 📚 Resources

- **Spark Documentation**: https://spark.apache.org/docs/3.4.1/
- **winutils GitHub**: https://github.com/cdarlint/winutils
- **Hadoop on Windows**: https://cwiki.apache.org/confluence/display/HADOOP2/WindowsProblems
- **Maven Guide**: https://maven.apache.org/guides/

---

## ✅ Final Configuration Summary

After following this guide, you should have:

```
Validated Configuration:
✅ Java 17 installed
✅ Maven 3.x installed
✅ Spark 3.4.1 in C:\dev\dev-tools\spark-3.4.1-bin-hadoop3
✅ Hadoop 3.3.5 in C:\dev\dev-tools\hadoop-3.3.5
✅ HADOOP_HOME = C:\dev\dev-tools\hadoop-3.3.5
✅ PATH includes Spark and Hadoop bin
✅ winutils.exe version 3.3.5 present
✅ hadoop.dll present
✅ Application compiles without errors
✅ Application runs successfully
```

---

**Last updated**: December 11, 2025  
**Version**: 1.0

