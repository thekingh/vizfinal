from math import sin, cos,pi
from random import random, randint
import sys
def rndPt(w,h):
   return random()*w, random()*h; 

def offset(x, s):
    return x + s * (1 - 2*random())

def offsetPoint(p, spread):
    return offset(p[0], spread), offset(p[1], spread)

def main(n, w, h):
    count = 0
    s = w if w < h else h
    while (count < n):
        cluster = rndPt(w,h), rndPt(w,h)
        spread = random()*s/10
        for i in range(randint(3,10)):
            pt1 = offsetPoint(cluster[0], spread)
            pt2 = offsetPoint(cluster[1], spread)
            p = pt1[0], pt1[1], pt2[0], pt2[1]

            print(",".join(list(map(lambda x: str(int(x)), p))))
            count += 1


if __name__ == "__main__":
    main(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]))
