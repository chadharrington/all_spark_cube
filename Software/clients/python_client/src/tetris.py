from itertools import chain
from math import cos, radians, sin
import time

from all_spark_cube_client import CubeClient
from colors import *

HOST='192.168.0.100'
PORT=12345

X_SIZE = 16
Y_SIZE = 16
Z_SIZE = 16

'''
BLOCK_SHAPES = {
    'I': [(0,0), (0,1), (0,2), (0,3), (0,4),         
          (1,4), (1,3), (1,2), (1,1), (1,0)],
    'J': [(0,0), (0,1), (1,1), (1,2), (1,3),
          (2,3), (2,2), (2,1), (2,0), (1,0)],
    'L': [(0,0), (0,1), (0,2), (0,3), (1,3),
          (1,2), (1,1), (2,1), (2,0), (1,0)],
    'O': [(0,0), (0,1), (0,2), (1,2), (2,2),
          (2,1), (2,0), (1,0)],
    'S': [(0,0), (0,1), (1,1), (1,2), (2,2),
          (3,2), (3,1), (2,1), (2,0), (1,0)],
    'T': [(0,0), (0,1), (1,1), (1,2), (2,2),
          (2,1), (3,1), (3,0), (2,0), (1,0)],
    'Z': [(0,0), (0,1), (-1,1), (-1,2), (0,2),
          (1,2), (1,1), (2,1), (2,0), (1,0)]}
'''

BLOCK_SHAPES = {
    'I': (cyan, [(x, y) for x in range(3) for y in range(9)]),
    'J': (blue, [(x, y) for x in range(5) for y in range(3)] + \
         [(x, y) for x in range(2, 5) for y in range(2, 7)]),
    'L': (orange, [(x, y) for x in range(5) for y in range(3)] + \
         [(x, y) for x in range(3) for y in range(2, 7)]),
    'O': (light_yellow, [(x, y) for x in range(5) for y in range(5)]),
    'S': (green, [(x, y) for x in range(5) for y in range(3)] + \
         [(x, y) for x in range(2, 7) for y in range(2, 5)]),
    'T': (magenta, [(x, y) for x in range(7) for y in range(3)] + \
         [(x, y) for x in range(2, 5) for y in range(2, 5)]),
    'Z': (red, [(x, y) for x in range(5) for y in range(3)] + \
         [(x, y) for x in range(-2, 3) for y in range(2, 5)])}

def flatten(l):
    return list(chain.from_iterable(l))


class XYPoint(object):
    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y


class XYZPoint(object):
    def __init__(self, x=0, y=0, z=0):
        self.x = x
        self.y = y
        self.z = z
    
    def __repr__(self):
        return '(x=%d, y=%d, z=%d)' % (self.x, self.y, self.z)

    def to_index(self):
        return (X_SIZE*Y_SIZE*self.z + X_SIZE*self.y + self.x)


class Shape(object):
    def __init__(self, xy_points, color=white, thickness=2, 
                 position=XYZPoint(), angle=0):
        self.xy_points = xy_points
        self.thickness = thickness
        self.position = position
        self.angle = angle
        self.color = color

    def translate_xy_point(self, point):
        c = cos(radians(self.angle))
        s = sin(radians(self.angle))
        new_x = point.x*c + point.y*s + self.position.x
        new_y = -point.x*s + point.y*c + self.position.y
        return int(round(new_x)), int(round(new_y))

    def get_global_points(self):
        translated_xy_points = [
            self.translate_xy_point(point) 
                        for point in self.xy_points]
        return [XYZPoint(x, y, t + self.position.z) 
                      for t in range(self.thickness)
                      for x, y in translated_xy_points]

    def make_move(self, move):
        if move == 0:           # down
            self.position.y = self.position.y - 1
        elif move == 1:         # right
            self.position.x = self.position.x + 1
        elif move == 2:         # left
            self.position.x = self.position.x - 1
        elif move == 3:         # cw rotation
            self.angle = self.angle + 90
        elif move == 4:         # ccw rotation
            self.angle = self.angle - 90
        else:
            raise Exception('Illegal move: %d' % move)


class Frame(object):
    def __init__(self, x_size=X_SIZE, y_size=Y_SIZE, z_size=Z_SIZE):
        self.x_size = x_size
        self.y_size = y_size
        self.z_size = z_size
        self.fill_buffer(black)
        self.shapes = []
        self.client = CubeClient(HOST, PORT)

    def add_shape(self, shape):
        self.shapes.append(shape)

    def is_point_out_of_range(self, point):
        if (point.x < 0) or (point.x >= self.x_size):
            return True
        if (point.y < 0) or (point.y >= self.y_size):
            return True
        if (point.z < 0) or (point.z >= self.z_size):
            return True
        return False

    def fill_buffer(self, color=black):
        self.buffer = [color for i in range(X_SIZE * Y_SIZE * Z_SIZE)]

    def render(self, shape):
        for point in shape.get_global_points():
            index = point.to_index()
            if self.is_point_out_of_range(point):
                continue  # skip points that are out of the frame
            self.buffer[point.to_index()] = shape.color

    def display(self):
        self.fill_buffer(black)
        for shape in self.shapes:
            self.render(shape)
        self.client.set_data(0, flatten(self.buffer))

paths = [('J', (0, 0, 3, 2, 2, 0, 2, 2, 0, 2,
                0, 0, 0, 0, 0, 0, 0, 2)),
         ('S', (0, 0, 0, 0, 0, 0, 1, 1, 0, 4, 0, 0, 
                0, 0, 1, 0, 0, 0, 0)),
         ('T', (0, 0, 0, 0, 1, 1, 1, 4, 0, 0, 
                0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0)),
         ('O', (0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0)),
         ('J', (0, 0, 0, 1, 1, 0, 4, 0, 2, 1, 1, 1, 0, 0, 
                0, 0, 1,  0)),
         ('I', (0, 0, 4, 1, 1, 0, 0, 1, 0)),
         ('S', (0, 0, 1, 4, 1, 1, 1, 1, 1, 1, 2, 1, 0, 0, 1, 0, 0, 0)),
         ('L', (0, 4, 1, 2, 0)),
]


def play_tetris():
    frame = Frame()
    for shape, moves in paths:
        color, points = BLOCK_SHAPES[shape]
        block = Shape(xy_points=[XYPoint(x, y) for x, y in points],
                      position=XYZPoint(6, 15, 0), color=color)
        frame.add_shape(block)
        for move in moves:
            block.make_move(move)
            frame.display()
            time.sleep(0.1)

def main():
    while True:
        play_tetris()
        time.sleep(30)


if __name__ == '__main__':
    main()
