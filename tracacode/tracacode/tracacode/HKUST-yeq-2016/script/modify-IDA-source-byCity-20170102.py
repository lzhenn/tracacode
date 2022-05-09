#!/usr/bin/python
# -*- coding: UTF-8 -*- 

#-----------------------------------------------
#   This is a shell script for modifying SMOKE
# inventory of IDA formatted pollutant sources,
# you should set the basic parameters as below. 
# Good Luck!
#               Last Modified on  2016-11-03
#-----------------------------------------------

#--------------User defined parameters--------------
# Inventory type (options: ARINV/MBINV/PTINV)
inv_type='PTINV'
#inv_type='ARINV'

# Inventory file path
inv_path='../data/obv/ptinve.2012PRDEIv2.3.GD_ALL.LARES.ida.161008.csv'

opt_path='../data/obv/ptinve.2012PRDEIv2.3.GD_ALL.LARES.ida.161008.modtest.csv'

#-------------------------------------
# City Dictionary
#
# Dict element:
#  'GuangZhou':['010',{1:0.5,2:0.3}]
#   City Name    Num,  Scale Dict
#
# Pollutant Numberi (example):
#  #DATA     SO2 NOx CO PM10 PM2_5 ...
#           1   2   3  4    5     ...
#
# Scale dict {1:0.5,2:0.3}:
#  --> SO2*0.5, NOx*0.3 
#-------------------------------------

dic_city={  'GuangZhou':['010',{1:1.5,2:1.3,3:7.0,4:0.1}],\
            'ShaoGuan':['020',{1:0.5,2:0.1}]}
#            'ShenZhen':['030',{1:0.5,2:0.5}],\
#            'ZhuHai':['040',{1:0.5,2:0.3}],\            
#            'ShanTou':['050',{1:0.5,2:0.3}],\
#            'FoShan':['060',{1:0.5,2:0.3}],\
#            'JiangMen':['070',{1:0.5,2:0.3}],\
#            'ZhanJiang':['080',{1:0.5,2:0.3}],\
#            'MaoMing':['090',{1:0.5,2:0.3}],\
#            'ZhaoQing':['120',{1:0.5,2:0.3}],\
#            'HuiZhou':['130',{1:0.5,2:0.3}],\
#            'MeiZhou':['140',{1:0.5,2:0.3}],\
#            'ShanWei':['150',{1:0.5,2:0.3}],\
#            'HeYuan':['160',{1:0.5,2:0.3}],\
#            'YangJiang':['170',{1:0.5,2:0.3}],\
#            'QingYuan':['180',{1:0.5,2:0.3}],\
#            'DongGuan':['190',{1:0.5,2:0.3}],\
#            'ZhongShan':['200',{1:0.5,2:0.3}],\
#            'ChaoZhou':['510',{1:0.5,2:0.3}],\
#            'JieYang':['520',{1:0.5,2:0.3}],\
#            'YunFu':['530',{1:0.5,2:0.3}],\

#--------------Parameter setting----------------------
if inv_type == 'ARINV':
    p_start = 15
    p_length= 10
    p_span  = 47
elif inv_type == 'MBINV':
    p_start = 25
    p_length= 10
    p_span  = 20
elif inv_type == 'PTINV':
    p_start = 249
    p_length= 13
    p_span  = 52

#---------------Operation----------------------
fr = open(inv_path, 'r')
fw = open(opt_path, 'w')

print '\n\nProducing %s\n' % inv_path
lines = fr.readlines()  # Read all inventory



print'----------File Head-----------'
for item in lines:
    if  item[0] == '#': # Headline
        print item
        fw.write(item)
        if item[1:5] == 'DATA':
            pollutant=item.split()
            print'----------File Head-----------'
    else: #Content
        w_flag=True   # Flag indicates whether we need to write a line with no modification
        for city,value in dic_city.items():
            if value[0] == item[2:5]:   # Test city number
                #Traversing pollutants and made modification
                
                p_org_line = 0 # Start positon to write original line data
                info_line = '' # Modification information displayed on screen
                item_rec = ''  # Written line
                
                for mdf_plt, scale_f in value[1].items():   
                    
                    pt_pos = p_start+(mdf_plt-1)*p_span # Current modified pollutent (CMP) start position
                    pt_value = float(item[pt_pos:pt_pos+p_length]) # CMP value
                    
                    # Here we start from 1, because pollutant[0]='#DATA'
                    info_line = info_line+'%4s: %*.3f x%d%%=%*.3f \n' % (pollutant[mdf_plt], 9, pt_value, scale_f*100, 9, pt_value*scale_f)
                    scl_itm=pt_value*scale_f #Change it!
                    item_rec=item_rec+item[p_org_line:pt_pos]+'%*.3f'% (p_length, scl_itm)
                    p_org_line=pt_pos+p_length
                
                print '%16s (%s):\n %s' % (item[0:15], city, info_line)
                item_rec=item_rec+item[p_org_line:]

                if item_rec[-1]=='\n':
                    fw.write(item_rec)
                else:
                    fw.write(item_rec+'\n')
                w_flag=False    # Line modified, no need to write the repeat line
            #CLZ IF: Test city number
        # CLZ FOR: Traversing city dict
        if w_flag:
            fw.write(item)
    # CLZ IF: Headline test
# CLZ FOR: Traversing the inventory file

print '%s written!' % opt_path 
fr.close()
fw.close()
