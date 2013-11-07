namespace py cube
namespace c_glib cube
namespace perl cube
namespace cpp cube
namespace java com.adaptivecomputing.cube
namespace php cube


service CubeInterface {
  oneway void set_data(1:i16 index, 2:list<i16> data)
}
