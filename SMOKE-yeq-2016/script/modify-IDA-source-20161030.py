#!/usr/bin/python
# -*- coding: UTF-8 -*- 

#-----------------------------------------------
#   This is a shell script for modifying SMOKE
# inventory of IDA formatted pollutant sources,
# you should set the basic parameters as below. 
# Good Luck!
#               Last Modified on  2016-10-31
#-----------------------------------------------

#--------------User defined parameters--------------
# Inventory type (options: ARINV/MBINV/PTINV)
inv_type='ARINV'

# Inventory file path
inv_path='../data/obv/2005/mobile/pathv1_hk_mobile.txt'

# Producing Pollutant ID [list style]
pt_ids=[1, 3, 5]

# Scaling factor [list or number]
scale_f=0.5

# Output file path
fn_plt_str=''
for mdf_plt in pt_ids:
    fn_plt_str='%s%s' % (fn_plt_str,mdf_plt) 
fn_plt_str='pol%s' % fn_plt_str

opt_path='../data/obv/2005/mobile/pathv1_hk_mobile-%s-%dpt.txt' % (fn_plt_str,scale_f*100)


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
                print 'We will modify %s by %dpt' % (pollutant[mdf_plt], (scale_f*100))
            print'<<<<<<<<MODIFICATIONS<<<<<<<<\n'
    else:
        p_org_line = 0 # Start positon to write original line data
        info_line = '' # Modification information displayed on screen
        item_rec = ''  # Written line

        for ii in range(len(pt_ids)):
            pt_pos = pt_ids[ii]-1
            pt_org = float(item[p_start+pt_pos*p_span:p_start+pt_pos*p_span+p_length])
            info_line = info_line+'%4s: %*.3f --> %*.3f | ' % (pollutant[pt_ids[ii]], 8, pt_org, 8, pt_org*scale_f)
            scl_itm=pt_org*scale_f
            item_rec=item_rec+item[p_org_line:p_start+pt_pos*p_span]+'%*.3f'% (p_length, scl_itm)
            p_org_line=p_start+ii*p_span+p_length
#        print info_line
        item_rec=item_rec+item[p_org_line:]
        fw.write(item_rec)

print '%s written!' % opt_path 
fr.close()
fw.close()
