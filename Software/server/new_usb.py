from ctypes import byref, create_string_buffer
from itertools import chain
import time

import pylibftdi

BYTES_PER_VOXEL = 3
NUM_ROWS = 16
NUM_COLS = 16
ROW_SIZE = NUM_COLS * BYTES_PER_VOXEL
PANEL_SIZE = NUM_ROWS * ROW_SIZE
CHUNK_SIZE = 4
NUM_CHUNKS_PER_ROW = ROW_SIZE / CHUNK_SIZE
NUM_NIBBLES_PER_CHUNK = CHUNK_SIZE * 2
FPGA_RESET = 0 
FPGA_RUN = 1

class USBError(Exception): pass

class CubeBoard(object):
    def __init__(self, serial_num):
        self.serial_num = serial_num
        self.device = pylibftdi.Device(serial_num)
        self.device.flush()
        self.set_fpga_mode(FPGA_RUN)
        self.set_panel_nums()

    def set_fpga_mode(self, mode):
        self.device.ftdi_fn.ftdi_set_bitmode(0x10 | mode, 0x20)
        self.device.ftdi_fn.ftdi_set_bitmode(0, 0x00)

    def set_panel_nums(self):
        self.send_command(1, 0) # request panel nums command
        panel_data = []
        while len(panel_data) < 4:
            data = self.device.read(1)
            if len(data):
                panel_data.append(data)
        self.panel_nums = [-1 for x in range(4)]
        for ch in panel_data:
            byte = ord(ch)
            self.panel_nums[(byte >> 4) - 1] = byte & 0x0f

    def send_command(self, command, operand):
        data = (command << 4) | operand
        buf = create_string_buffer(chr(data), 1)
        bytes_to_write = 1
        bytes_written = self.device.fdll.ftdi_write_data(
            byref(self.device.ctx), byref(buf), bytes_to_write)
        if bytes_written != bytes_to_write:
            raise USBError('Wrong number of bytes written. Expected ' + 
                           '%d, got %d' % (bytes_to_write, bytes_written))
    
    def send_chunk_data(self, panel, row, chunk, data):
        self.send_command(2, panel)
        self.send_command(3, row)
        self.send_command(4, chunk)
        for nibble in range(NUM_NIBBLES_PER_CHUNK):
            byte = data[nibble / 2]
            if nibble % 2:
                data_out = (byte & 0xf0) >> 4  # High nibble
            else:
                data_out = byte & 0x0f         # Low nibble
            self.send_command(nibble+5, data_out) # Send nibbles
        self.send_command(13, 0)  # Write chunk
            
    def send_row_data(self, panel, row, data):
        for chunk in range(NUM_CHUNKS_PER_ROW):
            start = chunk * CHUNK_SIZE
            end = start + CHUNK_SIZE
            self.send_chunk_data(panel, row, chunk, data[start:end])

    def send_panel_data(self, panel, data):
        for row in range(NUM_ROWS):
            start = row * ROW_SIZE
            end = start + ROW_SIZE
            self.send_row_data(panel, row, data[start:end])
        

class CubeDriver(object):
    def __init__(self):
        self.initialize_cube_boards()

    def initialize_cube_boards(self):
        self.driver = pylibftdi.Driver()
        devices = self.driver.list_devices()
        self.cube_boards = [CubeBoard(d[2]) for d in devices
                            if d[1] == "Cube Driver Board" ]
        for board in self.cube_boards:
            print "Serial #:", board.serial_num
            print "Panel #s:", board.panel_nums

    def send_frame_data(self, frame):
        for board in self.cube_boards:
            for board_panel, frame_panel in enumerate(board.panel_nums):
                start = frame_panel * PANEL_SIZE
                end = start + PANEL_SIZE
                board.send_panel_data(board_panel, frame[start:end])

    def test_row(self, row):
        for board in self.cube_boards:
            board.send_row_data(0, 0, row)

    def test_chunk(self, panel, row, chunk, data):
        for board in self.cube_boards:
            board.send_chunk_data(panel, row, chunk, data)

    def test_command(self, command, operand):
        for board in self.cube_boards:
            board.send_command(command, operand)

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

    for panel in range(2):
        for row in range(16):
            for col in range(16):
                print 'panel: %d row: %d col: %d' % (panel, row, col)
                data = make_mono_color_frame(white)
                make_red_voxel(panel, row, col, data)
                cube_driver.send_frame_data(data)
                #time.sleep(1)


if __name__ == '__main__':
    main()
