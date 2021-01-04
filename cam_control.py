
import serial
from bitarray import bitarray
import os
import time


class CAM:
    def __init__(self, port):
        os.system('tinyprog -b')
        time.sleep(1)
        self.port = serial.Serial(port, 9600)

    def get_tags(self):
        b = bitarray()
        self.port.write(b"f\r\n")
        x = self.port.readline()
        self.port.readline()
        b.frombytes(x[:-2])
        binary = b.to01()
        return binary

    def set_comparand(self, comparand):
        self.comparand = comparand
        self.port.write(b"a\r\n")
        self.port.write(comparand[::-1] + b"\r\n")

    def get_comparand(self):
        self.port.write(b"b\r\n")
        comparand = self.port.readline()
        self.port.readline()
        return comparand

    def get_mask(self):
        self.port.write(b"d\r\n")
        mask = self.port.readline()
        self.port.readline()
        return mask

    def set_mask(self,mask=bitarray([True]*32, endian='little')):
        self.mask = mask
        self.port.write(b"c\r\n")
        self.port.write(mask[::-1] + b"\r\n")
    
    def write(self):
        self.port.write(b"i\r\n")
    
    def set_high(self):
        self.port.write(b"g\r\n")

    def set_low(self):
        self.port.write(b"h\r\n")

    def read(self):
        self.port.write(b"j\r\n")
        out = self.port.readline()
        self.port.readline()
        return out

    def search(self):
        self.port.write(b"k\r\n")
    
    def select_first(self):
        self.port.write(b"e\r\n")

    def 

cam = CAM("/dev/tty.usbmodem14201")


print(cam.get_tags())

cam.set_high()
cam.set_low()


print(cam.get_tags())

cam.select_first()

print(cam.get_tags())

cam.set_comparand(b"funn")
print(cam.get_comparand())









        

    
