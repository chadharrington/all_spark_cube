from ctypes import byref, create_string_buffer, c_ubyte
from itertools import chain
import sys
import time

import pylibftdi

from shared_mem import get_shared_memory, detach_shared_memory, SHM_SIZE

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
SEND_BUFFER_LIMIT = 1000

'''
                  PC to FPGA Command Table
 
   Command           Description                       Operand
   data_bus_in[7:4]                                    data_bus[3:0]
   ----------------  --------------------------------  --------------------
   0 -               Unused / illegal                  N/A
   1 -               Request panel selector data       N/A
   2 -               Set panel address                 {2'b0, panel_addr}
   3 -               Set row address                   row_addr
   4 -               Set chunk address                 chunk_addr
   5 -               Set nibble 0 of chunk             nibble
   6 -               Set nibble 1 of chunk             nibble
   7 -               Set nibble 2 of chunk             nibble
   8 -               Set nibble 3 of chunk             nibble
   9 -               Set nibble 4 of chunk             nibble
   10 -              Set nibble 5 of chunk             nibble
   11 -              Set nibble 6 of chunk             nibble
   12 -              Set nibble 7 of chunk             nibble
   13 -              Write chunk                       N/A
   14 -              Unused / illegal                  N/A
   15 -              Unused / illegal                  N/A


                   FPGA to PC Command Table
 
   Command            Description                       Operand 
   data_bus_out[7:4]                                    data_bus[3:0]
   -----------------  --------------------------------  --------------------
   0 -                Unused / illegal                  N/A
   1 -                Set panel 0 number                panel_switches[3:0]
   2 -                Set panel 1 number                panel_switches[7:4]
   3 -                Set panel 2 number                panel_switches[11:8]
   4 -                Set panel 3 number                panel_switches[15:12]   
   5 -                Unused / illegal                  N/A
   6 -                Unused / illegal                  N/A
   7 -                Unused / illegal                  N/A
   8 -                Unused / illegal                  N/A
   9 -                Unused / illegal                  N/A
   10 -               Unused / illegal                  N/A
   10 -               Unused / illegal                  N/A
   11 -               Unused / illegal                  N/A
   12 -               Unused / illegal                  N/A
   13 -               Unused / illegal                  N/A
   14 -               Unused / illegal                  N/A
   15 -               Unused / illegal                  N/A
'''

class USBError(Exception): pass

class CubeBoard(object):
    def __init__(self, serial_num, shared_mem):
        self.serial_num = serial_num
        self.shmem = shared_mem
        self.send_buffer = []
        self.device = pylibftdi.Device(serial_num)
        self.device.flush()
        self.set_fpga_mode(FPGA_RUN)
        self.set_panel_nums()

    def set_fpga_mode(self, mode):
        self.device.ftdi_fn.ftdi_set_bitmode(0x10 | mode, 0x20)
        self.device.ftdi_fn.ftdi_set_bitmode(0, 0x00)

    def set_panel_nums(self):
        # Command 1=request panel nums 
        self.send_command(command=1, operand=0, send_immediately=True) 
        panel_data = []
        while len(panel_data) < 4:
            data = self.device.read(1)
            if len(data):
                panel_data.append(data)
        self.panel_nums = [-1 for x in range(4)]
        for ch in panel_data:
            byte = ord(ch)
            self.panel_nums[(byte >> 4) - 1] = byte & 0x0f

    def send_command(self, command, operand, send_immediately=False):
        data = chr((command << 4) | operand)
        self.send_buffer.append(data)
        if send_immediately or (len(self.send_buffer) >= SEND_BUFFER_LIMIT):
            self.send_buffer_to_device()
            
    def send_buffer_to_device(self):
        bytes_to_write = len(self.send_buffer)
        buf = create_string_buffer(''.join(self.send_buffer))
        bytes_written = self.device.fdll.ftdi_write_data(
            byref(self.device.ctx), byref(buf), bytes_to_write)
        if bytes_written != bytes_to_write:
            raise USBError('Wrong number of bytes written. Expected ' + 
                           '%d, got %d' % (bytes_to_write, bytes_written))
        self.send_buffer = []
    
    def send_chunk_data(self, panel, row, chunk, frame_index):
        self.send_command(2, panel)
        self.send_command(3, row)
        self.send_command(4, chunk)
        for nibble in range(NUM_NIBBLES_PER_CHUNK):
            byte = self.shmem[frame_index + nibble / 2]
            if nibble % 2:
                data_out = (byte & 0xf0) >> 4  # High nibble
            else:
                data_out = byte & 0x0f         # Low nibble
            self.send_command(nibble+5, data_out) # Send nibbles
        self.send_command(13, 0)  # Write chunk
            
    def send_row_data(self, panel, row, frame_index):
        for chunk in range(NUM_CHUNKS_PER_ROW):
            self.send_chunk_data(panel, row, chunk, 
                                 frame_index + chunk * CHUNK_SIZE)

    def send_panel_data(self, panel, frame_index):
        for row in range(NUM_ROWS):
            self.send_row_data(panel, row, frame_index + row * ROW_SIZE)
        

class CubeDriver(object):
    def __init__(self):
        self.shmaddr = get_shared_memory(perms=0444)
        data_type = c_ubyte * SHM_SIZE
        self.shmem = data_type.from_address(self.shmaddr)
        self.initialize_cube_boards()

    def __del__(self):
        detach_shared_memory(self.shmaddr)

    def initialize_cube_boards(self):
        self.driver = pylibftdi.Driver()
        devices = self.driver.list_devices()
        self.cube_boards = [CubeBoard(d[2], self.shmem) for d in devices
                            if d[1] == "Cube Driver Board" ]
        for board in self.cube_boards:
            print "Serial #:", board.serial_num
            print "Panel #s:", board.panel_nums

    def send_frame_data(self):
        for board in self.cube_boards:
            for board_panel, frame_panel in enumerate(board.panel_nums):
                board.send_panel_data(board_panel, frame_panel * PANEL_SIZE)

    def run(self):
        while True:
            self.send_frame_data()



def main():
    cube_driver = CubeDriver()
    cube_driver.run()

if __name__ == '__main__':
    main()
