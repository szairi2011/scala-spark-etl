# Scala Spark ETL Project

Spark ETL application written in Scala for batch data processing.

## 🚀 Quick Start

### Prerequisites
- Java 17
- Maven 3.x
- Apache Spark 3.4.1
- Scala 2.12

### Execution (Windows)

**Option 1 - Automated script** (recommended):
```powershell
.\run-spark-etl.ps1
```

**Option 2 - Manual command**:
```powershell
# IMPORTANT: Add Hadoop bin to PATH first
$env:PATH = "$env:HADOOP_HOME\bin;$env:PATH"
spark-submit --class com.company.etl.spark.Main --master local[*] target\scala-spark-etl-1.0-SNAPSHOT-uber.jar
```

### Compilation
```powershell
mvn clean package
```

## 📁 Project Structure

```
├── data/
│   ├── input/              # Source CSV files
│   └── output/             # Generated Parquet files
├── src/main/
│   ├── scala/              # Source code
│   │   └── com/company/etl/spark/
│   │       ├── Main.scala
│   │       ├── config/
│   │       ├── jobs/
│   │       └── utils/
│   └── resources/
│       └── application.conf
└── pom.xml
```

## 🎯 Features

The application performs the following operations:
1. **Read** CSV files from `data/input/`
2. **Transform** data (add timestamp, cleanup)
3. **Write** in Parquet format to `data/output/`

## 🔧 Windows Configuration

**⚠️ First time running on Windows?**

1. **Follow the installation guide**: [WINDOWS-SETUP.md](WINDOWS-SETUP.md)
2. **Verify your configuration**:
   ```powershell
   .\verify-setup.ps1
   ```
3. **In case of problems**: check the [FAQ.md](FAQ.md)

The guide covers:
- Installing Spark and Hadoop
- Configuring environment variables
- Installing winutils.exe
- Troubleshooting common issues

## 📝 Application Configuration

Modify `src/main/resources/application.conf`:
```hocon
app {
    inputPath = "data/input"
    outputPath = "data/output"
}
```

## 🧪 Tests

```powershell
mvn test
```

## 🧹 Maintenance

### Clean Spark Temp Files

During local development, Spark temp files can accumulate. Clean them periodically:

```powershell
.\cleanup-temp.ps1
```

This frees disk space by removing leftover temporary JAR files from `%TEMP%\spark-*` directories.

## 📚 Documentation

- **[WINDOWS-SETUP.md](WINDOWS-SETUP.md)** - Installation and configuration guide for Windows
- **[FAQ.md](FAQ.md)** - Frequently asked questions and troubleshooting
- **[pom.xml](pom.xml)** - Maven dependencies

