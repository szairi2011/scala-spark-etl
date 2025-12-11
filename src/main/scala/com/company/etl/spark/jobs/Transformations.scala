package com.company.etl.spark.jobs

import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions._

object Transformations {

  def transformSample(df: DataFrame): DataFrame = {
    df.withColumn("processed_at", current_timestamp())
      .withColumn("clean_name", trim(lower(col("name"))))
  }

}
