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
    stipend_list=np.arange(300,5100,100)
    cash_new_list=np.arange(300,5100,100)
    cash_old_list=np.arange(300,5100,100)
    
    for idx, stipend in enumerate(stipend_list):
        cash_all=0
        tax_all=0
        
        for imon in range(12):
            tax_new, cash_new = new_tax(stipend)
            tax_all=tax_all+tax_new
            cash_new=disconted_cash_flow(cash_new, imon, r)
            cash_all=cash_all+cash_new
        cash_all=cash_all+disconted_cash_flow(tax_all, 23, r)
        cash_new_list[idx]=cash_all
        
        cash_all=0
        tax_all=0
        
        for imon in range(12):
            tax_old, cash_old = old_tax(stipend)
            tax_all=tax_all+tax_old
            cash_old=disconted_cash_flow(cash_old, imon, r)
            cash_all=cash_all+cash_old
        cash_all=cash_all+disconted_cash_flow(tax_all, 23, r)
        cash_old_list[idx]=cash_all
        
    print(cash_new_list-cash_old_list)

    plt.subplot(211)
    plt.plot(stipend_list, cash_old_list, '-', color='gray', alpha=0.8, label='Old Tax System')
    plt.title('Cash Now')
    plt.plot(stipend_list, cash_new_list, '-', color='blue', label='New Tax System')
    plt.ylabel('cash now')
    plt.legend(loc='best', ncol=2 )
    plt.grid(True)
    
    plt.subplot(212)
    plt.plot(stipend_list, cash_new_list-cash_old_list, '-.', color='red', label='New Minus Old')
    plt.xlabel('stipend per month')
    plt.ylabel('cash now')
    plt.grid(True)
    plt.legend(loc='best', ncol=1 )
    
    plt.savefig('../fig/cash_now.png')

if __name__ == '__main__':
        mainfunc()

