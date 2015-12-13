from math import sin, cos,pi
from random import random
import sys
def twoPoints(r):
    rnd = random();
    tpi = 2*pi
    pt1 = (int(r*cos(tpi*rnd)+r), int(r*sin(tpi*rnd)+r))
    rnd = random();
    pt2 = (int(r*cos(tpi*rnd)+r), int(r*sin(tpi*rnd)+r))
    return pt1[0],pt1[1], pt2[0], pt2[1]


def main(n, w, h):
    s = w if w < h else h
    for i in range(n):
        p = twoPoints(s/2)
        print(",".join(list(map(lambda x: str(x), p))))

if __name__ == "__main__":
    main(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]))
