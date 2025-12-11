package com.company.etl.spark.config

import com.typesafe.config.{Config, ConfigFactory}

case class AppConfig(inputPath: String, outputPath: String)

object AppConfig {

  def load(): AppConfig = {
    val conf: Config = ConfigFactory.load()

    AppConfig(
      inputPath = conf.getString("app.inputPath"),
      outputPath = conf.getString("app.outputPath")
    )
  }

}