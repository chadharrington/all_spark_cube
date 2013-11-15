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
    def __init__(self, xy_points, thickness=2, position=XYZPoint(), angle=0,
                 color=white):
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
        if move == 0:
            self.position.y = self.position.y - 1
        elif move == 1:
            self.position.x = self.position.x + 1
        elif move == 2:
            self.position.x = self.position.x - 1
        elif move == 3:
            self.angle = self.angle + 90
        elif move == 4:
            self.angle = self.angle - 90
        else:
            raise Exception('Illegal move: %d' % move)

s = 10

shapes = {'I': [(0,0), (0,1), (0,2), (0,3), (0,4),                                                   (1,4), (1,3), (1,2), (1,1), (1,0)],
          'J':     def __init__(self, thickness=2, position=XYZPoint(), angle=0, color=white):
        points = [XYPoint(x,y) for x, y in [(0,0), (0,1), (1,1), (1,2), (1,3),
                                            (2,3), (2,2), (2,1), (2,0), (1,0)]]
        Shape.__init__(self, points, thickness, position, angle, color)

class LBlock(Shape):
    def __init__(self, thickness=2, position=XYZPoint(), angle=0, color=white):
        points = [XYPoint(x,y) for x, y in [(0,0), (0,1), (0,2), (0,3), (1,3),
                                            (1,2), (1,1), (2,1), (2,0), (1,0)]]
        Shape.__init__(self, points, thickness, position, angle, color)

class OBlock(Shape):
    def __init__(self, thickness=2, position=XYZPoint(), angle=0, color=white):
        points = [XYPoint(x,y) for x, y in [(0,0), (0,1), (0,2), (1,2), (2,2),
                                            (2,1), (2,0), (1,0)]]
        Shape.__init__(self, points, thickness, position, angle, color)

class SBlock(Shape):
    def __init__(self, thickness=2, position=XYZPoint(), angle=0, color=white):
        points = [XYPoint(x,y) for x, y in [(0,0), (0,1), (1,1), (1,2), (2,2),
                                            (3,2), (3,1), (2,1), (2,0), (1,0)]]
        Shape.__init__(self, points, thickness, position, angle, color)

class TBlock(Shape):
    def __init__(self, thickness=2, position=XYZPoint(), angle=0, color=white):
        points = [XYPoint(x,y) for x, y in [(0,0), (0,1), (1,1), (1,2), (2,2),
                                            (2,1), (3,1), (3,0), (2,0), (1,0)]]
        Shape.__init__(self, points, thickness, position, angle, color)

class ZBlock(Shape):
    def __init__(self, thickness=2, position=XYZPoint(), angle=0, color=white):
        points = [XYPoint(x,y) for x, y in [(0,0), (0,1), (-1,1), (-1,2), (0,2),
                                            (1,2), (1,1), (2,1), (2,0), (1,0)]]
        Shape.__init__(self, points, thickness, position, angle, color)


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


def main():
    frame = Frame()
    paths = [(JBlock, orange, (0, 0, 3, 2, 2, 0, 2, 2, 0, 2, 0, 0, 0)),
            (SBlock, cyan, (0, 0, 0, 4, 0, 2, 2, 0, 2, 0, 0, 0, 0))]
    for block_class, color, moves in paths:
        block = block_class(position=XYZPoint(6, 15, 0), color=color)
        frame.add_shape(block)
        for move in moves:
            block.make_move(move)
            frame.display()
            time.sleep(0.4)


if __name__ == '__main__':
    main()

