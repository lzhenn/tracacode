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
inv_path='/disk/hq233/huangyeq/forecast-test/smoke/cmaq/Smoke37.combine.v1/data/inventory/2012/point/ptinve.2012PRDEIv2.3.GD_ALL.LARES.ida.noshipline.csv'

# Producing Pollutant ID [list style]
pt_ids=[1]

# Scaling factor [list or number]
scale_f=0.5

# Output file path
fn_plt_str=''
for mdf_plt in pt_ids:
    fn_plt_str='%s%s' % (fn_plt_str,mdf_plt) 
fn_plt_str='pol%s' % fn_plt_str

opt_path='/disk/scratch/huangyeq/test_data/inv-test/PRD_point-%s-%dpt2.txt' % (fn_plt_str,scale_f*100)


#---------------Parameter setting----------------------
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
    if  item[0] == '#':
        print item
        fw.write(item)
        if item[1:5] == 'DATA':
            pollutant=item.split()
            print'----------File Head-----------'
            print '>>>>>>>>MODIFICATIONS>>>>>>>>'
            for mdf_plt in pt_ids:
                # Here we start from 1, because pollutant[0]='#DATA'
                print 'We will modify %s by %dpt' % (pollutant[mdf_plt], (scale_f*100))
            print'<<<<<<<<MODIFICATIONS<<<<<<<<\n'
    else:
        p_org_line = 0 # Start positon to write original line data
        info_line = '' # Modification information displayed on screen
        item_rec = ''  # Written line

        for mdf_plt in pt_ids:
            pt_pos = p_start+(mdf_plt-1)*p_span # Current modified pollutent (CMP) start position
            pt_value = float(item[pt_pos:pt_pos+p_length]) # CMP value
            info_line = info_line+'%4s: %*.3f --> %*.3f | ' % (pollutant[mdf_plt], 8, pt_value, 8, pt_value*scale_f)
            scl_itm=pt_value*scale_f #Change it!
            item_rec=item_rec+item[p_org_line:pt_pos]+'%*.3f'% (p_length, scl_itm)
            p_org_line=pt_pos+p_length
            #print info_line
        item_rec=item_rec+item[p_org_line:]
        if item_rec[-1]=='\n':
            fw.write(item_rec)
        else:
            fw.write(item_rec+'\n')

print '%s written!' % opt_path 
fr.close()
fw.close()
