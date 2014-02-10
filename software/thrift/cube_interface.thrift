namespace perl AllSparkCube

struct Color {
       1: required i16 red;
       2: required i16 green;
       3: required i16 blue
}

service CubeInterface {
  void set_data(1:list<Color> data)
}
