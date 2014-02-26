## General Cube Info

The All Spark Cube was built in 2012-2013 by Adaptive Computing and friends. More 
info is available here:
* www.allsparkcube.com
* [Hackaday Article](http://hackaday.com/2012/10/21/4096-leds-means-the-biggest-led-cube-ever/)

## Cube Client Libraries

To interact with the All Spark Cube, you'll need a client library for your 
preferred programming language. There are currently cube clients available for 
Python and Java. Skip to the relevant section for your language.

### Python Client 

#### Installation

Install the [Python client library](https://pypi.python.org/pypi/all_spark_cube_client/)
using pip. If you don't have pip installed, get it 
[here.](http://www.pip-installer.org/en/latest/installing.html)

`$ pip install all_spark_cube_client`

You can safely ignore the 10 or so warnings generated by pip, these are a 
part of the underlying [Thrift](http://thrift.apache.org/) library, and don't
affect the cube client library.

#### Usage
Here is the [Hello World](https://github.com/chadharrington/all_spark_cube/blob/master/software/clients/python_client/examples/helloworld.py) demo:
```
#!/usr/bin/env python

from all_spark_cube_client import CubeClient, Color, Colors


#HOST = 'localhost'
HOST = 'cube.ac'
PORT = 12345


client = CubeClient(HOST, PORT)

# Set all LEDs to blue. 
# Built-in colors are: red, green, blue, yellow, cyan, magenta, 
# white, black, gray, orange, pink, light_yellow, and dark_green
client.set_all_leds(Colors.blue)

# Set the first LED (#0) to red
client.set_led(0, Colors.red)

# Set the second LED (#1) to a custom color (teal-ish)
client.set_led(1, Color(100, 255, 95))

# Starting at LED #48, set 16 LEDs to yellow
client.set_led_range(48, 16, Colors.yellow)

# Set the last LED (#4095) to green
client.set_led(4095, Colors.green)

# Actually send the data to the cube
client.send();  

print 'Success...'
```
Download and run the [Hello World](https://github.com/chadharrington/all_spark_cube/blob/master/software/clients/python_client/examples/helloworld.py) demo:

```
$ wget -O helloworld.py http://git.io/hellopycube
$ python helloworld.py
```


### Java Client 

#### Installation

You have two options for installing the Java client:

#### Install via Maven

#### Direct Download 
If you don't use Maven, you can download and use the client jar directly:

`$ wget xxx`

After you have the jar, you should download and run the [Hello World](https://github.com/chadharrington/all_spark_cube/blob/master/software/clients/java_client/examples/HelloWorld.java) demo. 

```
$ wget -O HelloWorld.java http://git.io/hellojavacube
$ javac -cp .:xxx HelloWorld.java
$ java -cp .:xxx HelloWorld
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

1 - Install supervisor from http://supervisord.org/
2 - Run these commands:

```    
$ sudo yum install thrift boost
$ git clone https://github.com/chadharrington/all_spark_cube.git
$ cd all_spark_cube/software/thrift
$ make
$ cd ../server
$ sudo make install
$ sudo reboot now
```

The server will automatically start on reboot / powerup.

## Support

Having trouble? [Open an issue](https://github.com/chadharrington/all_spark_cube/issues).

## License

All code in this repository is licensed under an MIT license.

