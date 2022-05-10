import numpy as np
from timeit import default_timer as timer
from numba import vectorize

@vectorize(["float32(float32, float32)"], target='cuda')
def VectorAdd(a,b):
    a=a+b
    b=a-b
    a=a+2*b
    b=2*a+2*b
    a=2*b-a*a
    a=2*b-a*a
    a=2*b-a*a
    return a+b

def main():
    N=320000000

    A=np.ones(N, dtype=np.float32)
    B=np.ones(N, dtype=np.float32)
    C=np.zeros(N, dtype=np.float32)

    start = timer()
    '''
    A=A+B
    B=A-B
    A=A+2*B
    B=2*A+2*B
    A=2*B-A*A
    A=2*B-A*A
    A=2*B-A*A
    C=A+B
    '''
    C=VectorAdd(A, B)
    vectoradd_time = timer() -start
    print("C[:5]="+str(C[:5]))
    print("C[-5:]="+str(C[-5:]))

    print("VectorAdd took %f seconds" % vectoradd_time)

if __name__ == '__main__':
    main()
