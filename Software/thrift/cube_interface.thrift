namespace py all_spark_cube
namespace perl AllSparkCube


service CubeInterface {
  oneway void set_data(1:i16 index, 2:list<i16> data)
}
