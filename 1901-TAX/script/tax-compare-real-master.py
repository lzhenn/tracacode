#!/home/lzhenn/anaconda3/bin/python
# -*- coding: UTF-8 -*-

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# Function Def


# New tax system with monthly stipend less than 5000
def new_tax(income):
    if income <= 800:
        tax=0
    elif income <= 4000:
        tax=(income-800)*0.2
    else:
        tax=income*0.8*0.2
    return tax, income-tax

# Old tax system with monthly stipend less than 5000
def old_tax(income):
    if income <= 3500:
        tax=0
    else:
        tax=(income-3500)*0.03
    return tax, income-tax

# Discounted Cash Flow Method
def disconted_cash_flow(cash_advance, t, r):
    cash_now = (cash_advance/((1+r)**t))
    return cash_now

def mainfunc():

    r=56.54/10000.0
    #stipend_list=[800,1000,1200,1500,2000]
    stipend_list=[2000,2500,3000,4000,5000]
    #stipend_list=[800,1000,1200]
    
    cash_list_new=[]
    cash_list_old=[]

    for idx, stipend in enumerate(stipend_list):
 
        tax_back=0
        # tax back! before tax_all_new reset to zero
        if idx >= 1:
            tax_back=disconted_cash_flow(tax_all_new, idx*12+11, r)
        
        # new system
        tax_all_new=0
        tax_all_old=0
        for imon in range(12):
            tax_new, cash_new = new_tax(stipend)
            tax_all_new=tax_all_new+tax_new
            cash_new=disconted_cash_flow(cash_new, idx*12+imon, r)
            if len(cash_list_new)>0:
                cash_list_new.append(cash_new+cash_list_new[-1])
            else:
                cash_list_new.append(cash_new)
       
        cash_list_new[12*idx+11]=cash_list_new[12*idx+11]+tax_back
        
        # old system
        for imon in range(12):
            tax_old, cash_old = old_tax(stipend)
            tax_all_old=tax_all_old+tax_old
            cash_old=disconted_cash_flow(cash_old, idx*12+imon, r)
            if len(cash_list_old) >0:
                cash_list_old.append(cash_old+cash_list_old[-1])
            else:
                cash_list_old.append(cash_old)
# last year tax back
    for imon in range(12):
        cash_list_new.append(cash_list_new[-1])
        cash_list_old.append(cash_list_old[-1])
    cash_list_new[-1]=cash_list_new[-1]+disconted_cash_flow(tax_all_new, (len(stipend_list)-1)*12+11, r)
    print(np.array(cash_list_new)-np.array(cash_list_old))

    plt.subplot(211)
    plt.plot(cash_list_old, '-', color='gray', alpha=0.8, label='Old Tax System')
    plt.title('Cash Now')
    plt.plot(cash_list_new, '-', color='blue', label='New Tax System')
    plt.ylabel('cash now')
    plt.legend(loc='best', ncol=2 )
    plt.grid(True)
    
    plt.subplot(212)
    plt.plot(stipend_list, cash_new_list-cash_old_list, '-.', color='red', label='New Minus Old')
    plt.xlabel('stipend per month')
    plt.ylabel('cash now')
    plt.grid(True)
    plt.legend(loc='best', ncol=1 )
 
    plt.savefig('../fig/cash_timeseries.png')

if __name__ == '__main__':
        mainfunc()

