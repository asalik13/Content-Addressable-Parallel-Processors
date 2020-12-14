class Cam:
    def __init__(self, port):
        os.system('tinyprog -b')
        time.sleep(1)
        port = serial.Serial(port, 9600)

    def get_tags():
        b = bitarray.bitarray()
        port.write(b"f\r\n")
        x = port.readline()
        port.readline()
        b.frombytes(x[:-2])
        binary = b.to01()
        return binary

    def set_comparand(self, comparand):
        self.comparand = comparand
        port.write(b"a\r\n")
        port.write(comparand)

    def get_comparand(self):
        port.write(b"b\r\n")
        comparand = port.readline()
        port.readline()
        return comparand

    def get_mask(self):
        port.write(b"d\r\n")
        mask = port.readline()
        port.readline()
        return mask

    def set_mask(self,mask):
        self.mask = mask
        port.write(b"c\r\n")
        port.write(mask)
    
    def write():
        port.write(b"i\r\n")
    
    def set_high():
        port.write(b"g\r\n")

    def set_low():
        port.write(b"h\r\n")

    def read():
        port.write(b"j\r\n")
        out = port.readline()
        port.readline()
        return out

    def search():
        port.write(b"k\r\n")
    
    def select_first():
        port.write(b"e\r\n")

cam = new Cam()


        

    
