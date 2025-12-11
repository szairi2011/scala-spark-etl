package com.company.etl.spark

import com.company.etl.spark.config.AppConfig
import com.company.etl.spark.jobs.DemoJob
import com.company.etl.spark.utils.SparkBuilder

object Main {

  def main(args: Array[String]): Unit = {

    // Load configuration
    val config = AppConfig.load()

    // Create Spark Session
    val spark = SparkBuilder.build("MyMigrationJob")

    // Run your job
    DemoJob.run(spark, config)

    spark.stop()
  }

}