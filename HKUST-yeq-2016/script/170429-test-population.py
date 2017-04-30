#!/usr/bin/python
# -*- coding: UTF-8 -*-
#
#
#       L_Zealot
#       Feb 28, 2017
#
#
import scipy.io as sio 

mat_contents=sio.loadmat('../data/obv/population_output_D1.mat')

pop=mat_contents['population_output'] #list
print(len(pop[0]))
