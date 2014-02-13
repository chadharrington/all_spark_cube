## General Cube Info

The All Spark Cube was built in 2012-2013 by Adaptive Computing and friends. More 
info is available here:
* www.allsparkcube.com
* [Hackaday Article](http://hackaday.com/2012/10/21/4096-leds-means-the-biggest-led-cube-ever/)

## Cube Client Libraries

To interact with the All Spark Cube, you'll need a client library for your 
preferred programming language. There are currently cube clients available for 
Python and Java. Skip to the relevant section for your language.

### Python Client Install

1. Install the [Python client library](https://pypi.python.org/pypi/all_spark_cube_client/)
using pip. If you don't have pip installed, get it 
[here.](http://www.pip-installer.org/en/latest/installing.html)

`$ pip install all_spark_cube_client`

You can safely ignore the 10 or so warnings generated by pip, these are a 
part of the underlying [Thrift](http://thrift.apache.org/) library, and don't
affect the cube client library.

2. Download and run the [Hello World](https://github.com/chadharrington/all_spark_cube/blob/master/software/clients/python_client/examples/helloworld.py) demo:

```
$ wget -O helloworld.py http://git.io/hellopycube
$ python helloworld.py
```


### Java Client Install

You have two options for installing the Java client:

#### Install via Maven

#### Direct Download 
If you don't use Maven, you can download and use the client jar directly:

`$ wget xxx`

After you have the jar, you should download and run the [Hello World](https://github.com/chadharrington/all_spark_cube/blob/master/software/clients/java_client/examples/HelloWorld.java) demo. 

```
$ wget -O HelloWorld.java http://git.io/hellojavacube
$ javac -cp xxx HelloWorld.java
$ java -cp xxx HelloWorld
```
The cube should update and you should see "Success..." on your command line. If 
you get errors instead, open the HelloWorld.java file and make sure the HOST 
parameter is set to the correct network address for the cube. You should also 
make sure the cube is turned on and reachable over the network.


## Cube Server Install
These instructions are only relevant for installing the server onto the computer 
inside the All Spark Cube. Cube users only need to install a client library, not
the server code.

The server code and these instructions assume a CentOS / RHEL server.

```    
$ sudo yum install thrift boost supervisor
$ git clone https://github.com/chadharrington/all_spark_cube.git
$ cd all_spark_cube/software
$ make
$ cd server
$ sudo make install
$ sudo reboot now
```

The server will automatically start on reboot / powerup.

## Support

Having trouble? [Open an issue](https://github.com/chadharrington/all_spark_cube/issues).

## License

All code in this repository is licensed under an MIT license.

