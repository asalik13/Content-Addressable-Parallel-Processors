import os
import time
import serial
from bitarray import bitarray


class CAPP:
    def __init__(self, port):
        self.port = serial.Serial(port, 9600, timeout = 0.01)
        self.set_comparand()
        # self.set_mask()

    def get_tags(self):
        b = bitarray()
        self.port.write(b"f")
        x = self.port.read(2)
        b.frombytes(x)
        binary = b.to01()
        return binary

    def set_comparand(self, comparand=bitarray(32*[False]).tobytes()):

        self.comparand = comparand + (4 - len(comparand))* b"\0"
        self.port.write(b"a")
        self.port.write(self.comparand[::-1])

    def get_comparand(self):
        self.port.write(b"b")
        comparand = self.port.read(4)
        return comparand

    def get_mask(self):
        self.port.write(b"d")
        mask = self.port.read(4)
        return mask

    def set_mask(self, mask=bitarray([True]*32).tobytes()):
        self.mask = mask
        self.port.write(b"c")
        self.port.write(self.mask[::-1])
    
    def write(self, word):
        self.set_comparand(word)
        self.set_mask()
        self.port.write(b"i")
        self.set_mask(bitarray(32*[False]).tobytes())
        self.port.write(b"i")


    
    def set_high(self):
        self.port.write(b"g")

    def set_low(self):
        self.port.write(b"h")
        
    def set(self):
        self.set_high()
        self.set_low()

    def read(self):
        self.port.write(b"j")
        out = self.port.read(4)
        return out

    def search(self, comparand=bitarray(32*[False]).tobytes(), mask=bitarray(32*[True]).tobytes()):
        self.set()      
        self.set_comparand(comparand)
        self.set_mask(mask)
        self.port.write(b"k")

    
    def select_first(self):
        self.port.write(b"e")


capp = CAPP("COM4")


iter = 100
tests = [True] * iter

for i in range(iter):
    capp.set()
    
    tests[i] = (capp.get_tags() == "1111111111111111")
    capp.write(b"")  # So later we can select empty slots...
    capp.search(b"")
    capp.select_first()
    tests[i] = tests[i] and (capp.get_tags() == "0000000000000001")
    capp.write(b"1111")
    capp.search(b"")
    capp.select_first()
    tests[i] = tests[i] and (capp.get_tags() == "0000000000000010")
    capp.write(b"1122")
    output = capp.read()
    tests[i] = tests[i] and (output == b"1122")
    capp.search(b"1111")
    tests[i] = tests[i] and (capp.get_tags() == "0000000000000001")
    capp.search(b"1122")
    tests[i] = tests[i] and (capp.get_tags() == "0000000000000010")
    capp.search(b"2222")
    tests[i] = tests[i] and (capp.get_tags() == "0000000000000000")
    capp.search(b"1111", bitarray(16*[True] + 16*[False]).tobytes())
    tests[i] = tests[i] and (capp.get_tags() == "0000000000000011")

count = len([i for i in tests if i is True])
print("Success Rate: ", count/iter * 100, "%")
