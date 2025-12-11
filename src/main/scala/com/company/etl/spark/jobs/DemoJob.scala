package com.company.etl.spark.jobs

import com.company.etl.spark.config.AppConfig
import com.company.etl.spark.jobs.Transformations.transformSample
import org.apache.spark.sql.SparkSession

object DemoJob {

  def run(spark: SparkSession, config: AppConfig): Unit = {

    val df = spark.read
      .option("header", "true")
      .csv(config.inputPath)

    val transformed = transformSample(df)

    transformed.write.mode("overwrite").parquet(config.outputPath)
  }
}
