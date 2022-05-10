import matplotlib.pyplot as plt

wesst0, atao, k, c, dt, nstep = 8, 0.001, 0.01, 0.01, 0.01, 0
wesst=[wesst0]

while (wesst[nstep]>0):
    wesst.append(wesst[nstep]-k*atao*dt)
    atao=atao-c*(wesst[nstep]-wesst0)*dt
    print('NSTEP: %3d, WESST: %6.2f, Tao Anomaly: %6.2f' % (nstep, wesst[nstep], atao))
    nstep = nstep+1

# Plot
plt.plot(wesst,'-o')
plt.xlabel('Nstep')# make axis labels
plt.ylabel('delta WESST')
plt.show()

