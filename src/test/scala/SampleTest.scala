import org.scalatest.funsuite.AnyFunSuite
import org.apache.spark.sql.SparkSession
import com.company.etl.spark.jobs.Transformations._

class SampleTest extends AnyFunSuite {

  val spark: SparkSession =
    SparkSession.builder().master("local[*]").getOrCreate()

  import spark.implicits._

  test("transformSample adds processed_at column") {

    val df = Seq(("John")).toDF("name")

    val out = transformSample(df)

    assert(out.columns.contains("processed_at"))
    assert(out.columns.contains("clean_name"))
    assert(out.filter($"clean_name" === "john").count() == 1)
  }

}