
import serial
from bitarray import bitarray
import os
import time


class CAM:
    def __init__(self, port):
        self.port = serial.Serial(port, 9600)

    def get_tags(self):
        b = bitarray()
        self.port.write(b"f\r\n")
        x = self.port.readline()
        self.port.readline()
        b.frombytes(x[:-2])
        binary = b.to01()
        return binary

    def set_comparand(self, comparand=bitarray(32*[False]).tobytes()):

        self.comparand = comparand + (4 - len(comparand))* b"\0"
        self.port.write(b"a\r\n")
        self.port.write(self.comparand[::-1] + b"\r\n")

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

    def set_mask(self, mask=bitarray([True]*32).tobytes()):
        self.mask = mask
        self.port.write(b"c\r\n")
        self.port.write(self.mask[::-1] + b"\r\n")
    
    def write(self, word):
        prevComparand = self.comparand
        prevMask = self.mask
        self.set_comparand(word)
        self.set_mask()
        self.port.write(b"i\r\n")
        self.set_comparand(prevComparand)
        self.set_mask(prevMask)

    
    def set_high(self):
        self.port.write(b"g\r\n")
        time.sleep(0.01)

    def set_low(self):
        self.port.write(b"h\r\n")
        time.sleep(0.01)
        
    def set(self):
        self.set_high()
        self.set_low()

    def read(self):
        self.port.write(b"j\r\n")
        out = self.port.readline()
        self.port.readline()
        return out

    def search(self, comparand=bitarray(32*[False]).tobytes(), mask=bitarray(32*[True]).tobytes()):
        self.set()      
        prevComparand = self.comparand
        prevMask = self.mask
        self.set_comparand(comparand)
        self.set_mask(mask)
        self.port.write(b"k\r\n")
        self.set_comparand(prevComparand)
        self.set_mask(prevMask)
    
    def select_first(self):
        self.port.write(b"e\r\n")


cam = CAM("/dev/tty.usbmodem14201")

cam.set_comparand()
cam.set_mask()

cam.set()
print(cam.get_tags())

cam.select_first()
print(cam.get_tags())



























        

    
