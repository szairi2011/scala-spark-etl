package com.company.etl.spark.utils

import org.apache.spark.sql.SparkSession

object SparkBuilder {
  def build(appName: String): SparkSession = {
    SparkSession.builder()
      .appName(appName)
      .config("spark.sql.shuffle.partitions", "200")
      .getOrCreate()
  }
}
