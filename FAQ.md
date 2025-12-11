# FAQ - Frequently Asked Questions

Common issues and solutions when running the Spark ETL application on Windows.

---

## ⚠️ CRITICAL: Use PowerShell, Not CMD

**The application ONLY works in PowerShell, NOT in Windows CMD.**

When running manually, use this single-line command:
```powershell
$env:PATH = "$env:HADOOP_HOME\bin;$env:PATH"; spark-submit --class com.company.etl.spark.Main --master local[*] target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

**Recommended**: Use the provided script which handles this automatically:
```powershell
.\run-spark-etl.ps1
```

---

## ✅ Final Configuration Checklist

Before running the application, ensure all items below are checked:

```
✓ Java 17 installed and in PATH
✓ Maven 3.x installed and in PATH
✓ Spark 3.4.1 installed and in PATH
✓ HADOOP_HOME defined and valid (pointing to hadoop-3.3.5)
✓ winutils.exe present in HADOOP_HOME/bin
✓ hadoop.dll present in HADOOP_HOME/bin
✓ Project compiled (uber JAR exists)
✓ Input data available (data/input directory exists)
✓ Terminal/IDE restarted after environment variable configuration
```

### Quick Verification

Run the automated verification script:
```powershell
.\verify-setup.ps1
```

This will check all requirements and report any issues.

---

## ❌ Error: `UnsatisfiedLinkError: NativeIO$Windows.access0`

### Symptom
```
Exception in thread "main" java.lang.UnsatisfiedLinkError: 
'boolean org.apache.hadoop.io.nativeio.NativeIO$Windows.access0(java.lang.String, int)'
```

### Root Cause

Hadoop's native DLL (`hadoop.dll`) is not found because `HADOOP_HOME\bin` is not in the PATH when spark-submit runs.

### Solution (THE FIX THAT WORKS)

**Run this single-line command:**

```powershell
$env:PATH = "$env:HADOOP_HOME\bin;$env:PATH"; spark-submit --class com.company.etl.spark.Main --master local[*] target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

**OR use the script (it does this automatically):**
```powershell
.\run-spark-etl.ps1
```

### Alternative Solutions

#### If the above doesn't work - Restart Terminal/IDE

If you just configured environment variables:

**In IntelliJ IDEA**:
1. Close IntelliJ IDEA completely
2. Restart IntelliJ IDEA
3. Open a new terminal
4. Verify: `echo $env:HADOOP_HOME` → should show `C:\dev\dev-tools\hadoop-3.3.5`

**In external PowerShell**:
1. Close your PowerShell window
2. Open a new PowerShell window
3. Verify: `echo $env:HADOOP_HOME` → should show `C:\dev\dev-tools\hadoop-3.3.5`

#### Solution 2: Reload HADOOP_HOME in Current Terminal

If you cannot restart:

```powershell
# Reload variable from Windows registry
$env:HADOOP_HOME = [Environment]::GetEnvironmentVariable("HADOOP_HOME", "User")

# Verify
echo $env:HADOOP_HOME

# Run application
spark-submit --class com.company.etl.spark.Main --master local[*] target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

#### Solution 3: Verify winutils.exe

```powershell
# Check HADOOP_HOME is defined
echo $env:HADOOP_HOME

# Check winutils.exe exists
Test-Path "$env:HADOOP_HOME\bin\winutils.exe"

# Check hadoop.dll exists
Test-Path "$env:HADOOP_HOME\bin\hadoop.dll"
```

If files are missing, see [WINDOWS-SETUP.md](WINDOWS-SETUP.md#installing-winutilsexe).

---

## ❌ Error: `spark-submit` not recognized

### Symptom
```
spark-submit : The term 'spark-submit' is not recognized as the name of a cmdlet
```

### Cause
Spark is not in PATH

### Solution

**Temporary (current session only)**:
```powershell
$env:PATH += ";C:\dev\dev-tools\spark-3.4.1-bin-hadoop3\bin"
spark-submit --version
```

**Permanent**:
```powershell
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$sparkPath = "C:\dev\dev-tools\spark-3.4.1-bin-hadoop3\bin"
[Environment]::SetEnvironmentVariable("PATH", "$currentPath;$sparkPath", "User")
```

**Then restart your terminal.**

---

## ❌ Error: Maven BUILD FAILURE

### Symptom
```
[ERROR] BUILD FAILURE
[ERROR] Failed to execute goal...
```

### Solutions

**Solution 1: Clean and recompile**
```powershell
mvn clean
mvn package -DskipTests
```

**Solution 2: Remove corrupted Maven cache**
```powershell
# Remove cached Spark dependencies
Remove-Item -Recurse -Force "$env:USERPROFILE\.m2\repository\org\apache\spark"

# Recompile
mvn clean package -DskipTests
```

**Solution 3: Verify Java version**
```powershell
java -version
# Should show Java 17
```

---

## ❌ Error: CSV files not found

### Symptom
```
INFO InMemoryFileIndex: It took X ms to list leaf files for 0 paths
```
or
```
org.apache.spark.sql.AnalysisException: Path does not exist: file:/C:/dev/projects/scala-spark-etl/data/input
```

### Cause
The `data/input` directory is empty or does not exist

### Solution

**Option 1: Use the automated script**
```powershell
.\run-spark-etl.ps1
```
The script automatically creates a test CSV file.

**Option 2: Create manually**
```powershell
# Create directory
New-Item -ItemType Directory -Force -Path "data\input"

# Create test CSV file
@"
id,name,age,city
1,John Doe,30,New York
2,Jane Smith,25,Los Angeles
3,Bob Johnson,35,Chicago
"@ | Out-File -FilePath "data\input\sample.csv" -Encoding UTF8
```

---

## ⚠️ Warning: `Unable to load native-hadoop library`

### Symptom
```
WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... 
using builtin-java classes where applicable
```

### Impact
**None** - This is a warning, not an error. The application works normally.

### Explanation
Hadoop uses fallback Java implementations if native libraries are not available.

### Suppress Warning (Optional)
```powershell
spark-submit --class com.company.etl.spark.Main \
  --master local[*] \
  --conf spark.hadoop.io.native.lib.available=false \
  target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

---

## ❌ Error: `HADOOP_HOME is not set`

### Symptom
```
ERROR: HADOOP_HOME is not set
```

### Solution

**Set HADOOP_HOME permanently**:
```powershell
[Environment]::SetEnvironmentVariable("HADOOP_HOME", "C:\dev\dev-tools\hadoop-3.3.5", "User")
```

**Then restart your terminal/IDE.**

---

## ✅ Environment Setup Verification

### Automated Verification (Recommended)

**Run the automated verification script**:
```powershell
.\verify-setup.ps1
```

This script automatically checks:
```
✓ Java 17
✓ Maven 3.x
✓ Spark 3.4.1
✓ HADOOP_HOME defined and valid
✓ winutils.exe present
✓ hadoop.dll present
✓ Project compiled (uber JAR)
✓ Input data available
```

### Manual Verification

If you prefer to verify manually, here are the essential commands:

```powershell
# 1. Java 17
java -version
# Expected: "17.0.x"

# 2. Maven
mvn -version
# Expected: "Apache Maven 3.x"

# 3. Spark
spark-submit --version
# Expected: "version 3.4.1"

# 4. HADOOP_HOME
echo $env:HADOOP_HOME
# Expected: "C:\dev\dev-tools\hadoop-3.3.5"

# 5. winutils.exe
Test-Path "$env:HADOOP_HOME\bin\winutils.exe"
# Expected: True

# 6. hadoop.dll
Test-Path "$env:HADOOP_HOME\bin\hadoop.dll"
# Expected: True

# 7. Project compiled
Test-Path "target\scala-spark-etl-1.0-SNAPSHOT-uber.jar"
# Expected: True
```

### Quick Start Checklist

Before running the application, ensure:

| Item | Verification Command | Status |
|------|---------------------|--------|
| **Java 17** | `java -version` | ☐ |
| **Maven 3.x** | `mvn -version` | ☐ |
| **Spark 3.4.1** | `spark-submit --version` | ☐ |
| **HADOOP_HOME** | `echo $env:HADOOP_HOME` | ☐ |
| **winutils.exe** | `Test-Path "$env:HADOOP_HOME\bin\winutils.exe"` | ☐ |
| **hadoop.dll** | `Test-Path "$env:HADOOP_HOME\bin\hadoop.dll"` | ☐ |
| **Uber JAR** | `Test-Path "target\scala-spark-etl-1.0-SNAPSHOT-uber.jar"` | ☐ |
| **Terminal restarted** | After configuring variables | ☐ |

**If all items are checked** → Run `.\run-spark-etl.ps1`

**If any item is missing** → See [WINDOWS-SETUP.md](WINDOWS-SETUP.md) or solutions below in this FAQ

---

## ❓ Application is slow

### Possible Optimizations

**1. Increase memory**:
```powershell
spark-submit --class com.company.etl.spark.Main \
  --master local[*] \
  --driver-memory 4g \
  --executor-memory 4g \
  target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

**2. Adjust parallelism**:
```powershell
spark-submit --class com.company.etl.spark.Main \
  --master local[4] \
  --conf spark.sql.shuffle.partitions=100 \
  target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

**3. Enable compression**:
```powershell
spark-submit --class com.company.etl.spark.Main \
  --master local[*] \
  --conf spark.sql.parquet.compression.codec=snappy \
  target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

---

## ❓ How to view detailed logs?

**Option 1: Console logs**
Logs are displayed by default. To filter:
```powershell
spark-submit ... 2>&1 | Select-String "ERROR"
```

**Option 2: Logs to file**
```powershell
spark-submit ... > logs.txt 2>&1
```

**Option 3: Spark UI**
During execution, open your browser:
```
http://localhost:4040
```

---

## ❓ How to add custom CSV data?

1. **Place your CSV files in** `data/input/`
2. **Ensure they have a header** (first line with column names)
3. **Run the application** with `.\run-spark-etl.ps1`
4. **Results are in** `data/output/`

Valid CSV example:
```csv
id,name,age,city
1,Alice,25,Paris
2,Bob,30,Lyon
```

---

## ❓ Where to find more help?

- **Complete installation guide**: [WINDOWS-SETUP.md](WINDOWS-SETUP.md)
- **Official Spark documentation**: https://spark.apache.org/docs/3.4.1/
- **winutils guide**: https://github.com/cdarlint/winutils
- **Project README**: [README.md](README.md)

---

## 🔧 Quick Troubleshooting

### First Step: Complete Verification

**Run the verification script** to quickly identify the problem:
```powershell
.\verify-setup.ps1
```

### If error persists after verification

1. **Check the [Environment Setup Verification](#environment-setup-verification)** above
2. **Restart your terminal/IDE** if you just configured variables
3. **Search for your specific error** in this FAQ
4. **Consult the complete guide**: [WINDOWS-SETUP.md](WINDOWS-SETUP.md)

### Most Common Errors

| Error | Quick Fix | Details |
|-------|-----------|---------|
| `UnsatisfiedLinkError` | Restart IDE | [See section](#-error-unsatisfiedlinkerror-nativeiowindowsaccess0) |
| `spark-submit not recognized` | Configure PATH | [See section](#-error-spark-submit-not-recognized) |
| `HADOOP_HOME is not set` | Define variable | [See section](#-error-hadoop_home-is-not-set) |
| `BUILD FAILURE` | Maven clean | [See section](#-error-maven-build-failure) |

---

## ⚠️ Warning: Failed to delete temp files (HARMLESS)

### Symptom
```
WARN SparkEnv: Exception while deleting Spark temp dir
java.io.IOException: Failed to delete: C:\Users\...\AppData\Local\Temp\spark-...\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

### Is This an Error?

**NO - This is a harmless warning, NOT an error.**

✅ **Your application completed successfully**  
✅ **Output files were generated correctly**  
✅ **This warning appears AFTER the job finishes**

### Why Does This Happen?

On Windows, file locks prevent Spark from deleting temporary JAR files during shutdown. The files are locked because:
- Windows holds file handles longer than Linux
- Antivirus software may scan the files
- Java process hasn't fully released the files yet

### What Should You Do?

**Nothing!** The warning is harmless and temp files are automatically managed:

✅ **Automatic cleanup**: The `run-spark-etl.ps1` script automatically cleans temp files before each run  
✅ **Project-level temp**: Spark uses `spark-temp/` directory for most temporary files  
✅ **System temp**: Some files (like JARs) still go to `%TEMP%` but are cleaned on next run

**Manual cleanup (optional)**:
If you want to clean temp files immediately without running the app:
```powershell
.\cleanup-temp.ps1
```

### How to Verify Success?

Check that your output was generated:
```powershell
dir data\output
```

You should see:
- `_SUCCESS` file
- `.parquet` files with data

If these files exist, **your job ran successfully**.

---

**Last updated**: December 11, 2025

