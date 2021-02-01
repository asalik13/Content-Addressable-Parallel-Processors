
import serial
from bitarray import bitarray
import os
import time


class CAM:
    def __init__(self, port):
        self.port = serial.Serial(port, 9600, timeout = 0.01)
        self.set_comparand()
        self.set_mask()

    def get_tags(self):
        b = bitarray()
        self.port.write(b"f\r")
        x = self.port.readline()
        self.port.readline()
        b.frombytes(x[:-2])
        binary = b.to01()
        print(binary)
        return binary

    def set_comparand(self, comparand=bitarray(32*[False]).tobytes()):

        self.comparand = comparand + (4 - len(comparand))* b"\0"
        self.port.write(b"a\r")
        self.port.write(self.comparand[::-1] + b"\r")

    def get_comparand(self):
        self.port.write(b"b\r")
        comparand = self.port.readline()
        self.port.readline()
        return comparand

    def get_mask(self):
        self.port.write(b"d\r")
        mask = self.port.readline()
        self.port.readline()
        return mask

    def set_mask(self, mask=bitarray([True]*32).tobytes()):
        self.mask = mask
        self.port.write(b"c\r")
        self.port.write(self.mask[::-1] + b"\r")
    
    def write(self, word):
        self.set_comparand(word)
        self.set_mask()
        self.port.write(b"i\r")
        self.set_mask(bitarray(32*[False]).tobytes())
        self.port.write(b"i\r")


    
    def set_high(self):
        self.port.write(b"g\r")

    def set_low(self):
        self.port.write(b"h\r")
        
    def set(self):
        self.set_high()
        self.set_low()

    def read(self):
        self.port.write(b"j\r")
        out = self.port.readline()
        self.port.readline()
        print(out)
        return out

    def search(self, comparand=bitarray(32*[False]).tobytes(), mask=bitarray(32*[True]).tobytes()):
        self.set()      
        self.set_comparand(comparand)
        self.set_mask(mask)
        self.port.write(b"k\r")

    
    def select_first(self):
        self.port.write(b"e\r")


cam = CAM("/dev/tty.usbmodem14101")


# +
def basicApiTest():
    cam.set()
    cam.write(b"0")
    cam.select_first()
    print(cam.read(), "should be 0")
    cam.write(b"1")
    print(cam.read(), "should be 1")
    cam.search(b"0")
    print(cam.get_tags(), "should be all 1s with a trailing 0")
    cam.search(b"1")
    print(cam.get_tags(), "should be all 0s with a trailing 1")    
    
    
    
    
# -
iter = 10
count = iter
tests = [True] * iter

for i in range(iter):
    cam.set()
    tests[i] = (cam.get_tags() == "1111111111111111")
    cam.write(b"1")
    tests[i] = tests[i] and (cam.read() == b'1\x00\x00\x00\r\n')
    """cam.select_first()
    tests[i] = tests[i] and (cam.get_tags() == "0000000000000001")"""



count = len([i for i in tests if i is True])
print("Success Rate: ", count/iter * 100, "%")




























