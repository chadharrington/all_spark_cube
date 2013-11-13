#!/usr/bin/env python

from itertools import chain
from random import randint
import time

from all_spark_cube_client import CubeClient


HOST='192.168.0.100'
PORT=12345

def make_red_voxel(panel, row, col, data):
    pos = (256*panel + 16*row + col) * 3
    data[pos+1] = 0
    data[pos+2] = 0
    
def make_mono_color_frame(color):
    rows = [color for x in range(4096)]
    data = list(chain.from_iterable(rows))
    return data
    

def main():

    yellow = (255, 255, 0)
    cyan = (0, 255, 255)
    purple = (255, 0, 255)
    red = (255, 0, 0)
    green = (0, 255, 0)
    blue = (0, 0, 255)
    white = (255, 255, 255)
    black = (0, 0, 0)
    gray = (100, 100, 100)
    dark_green = (36, 84, 48)

    data = [white for x in range(4096)]
    data = list(chain.from_iterable(data))

    client = CubeClient(HOST, PORT)

    frames = 0
    begin = time.clock()
    for panel in range(16):
        for row in range(16):
            print 'panel %d, row %d' % (panel, row)
            for col in range(16):
                data = make_mono_color_frame(white)
                make_red_voxel(panel, row, col, data)
                client.set_data(0, data)
                frames += 1
    end = time.clock()
    duration = end - begin
    print "%d frames in %f secs. %f fps." % (frames, duration, frames / duration)

s = '''
def make_red_voxel(panel, row, col, data):
    pos = (256*panel + 16*row + col) * 3
    data[pos+1] = 0
    data[pos+2] = 0
    
def make_mono_color_frame(color):
    rows = []
    for x in range(16):
        rows.append([color for x in range(16)])  
    rows = list(chain.from_iterable(rows))
    rows = list(chain.from_iterable(rows))
    panel = rows * 4
    data = panel * 16
    return data
    

def main():
    cube_driver = CubeDriver()
    yellow = (255, 255, 0)
    cyan = (0, 255, 255)
    purple = (255, 0, 255)
    red = (255, 0, 0)
    green = (0, 255, 0)
    blue = (0, 0, 255)
    white = (255, 255, 255)
    black = (0, 0, 0)
    gray = (100, 100, 100)
    dark_green = (36, 84, 48)

    frames = 0
    start = time.clock()
    for panel in range(2):
        for row in range(16):
            for col in range(16):
                data = make_mono_color_frame(white)
                make_red_voxel(panel, row, col, data)
                cube_driver.send_frame_data(data)
                frames += 1
    end = time.clock()
    duration = end - start
    print '%d frames in %.2f secs. %.2f frames per second.' % (
        frames, duration, frames / duration)

'''

if __name__ == '__main__':
    main()

