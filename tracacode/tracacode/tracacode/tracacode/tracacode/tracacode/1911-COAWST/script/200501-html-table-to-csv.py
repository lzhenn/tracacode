# coding=utf-8
"""
@author: jiajiknag
程序功能： 获取HTML表格并写入CSV文件
"""
import csv
from urllib.request import urlopen
from bs4 import BeautifulSoup

bouys=['QF305','QF306','QF307','QF308','SF301','SF304','SF305']

for bouy in bouys:
    html = urlopen("http://121.33.201.243/systems/HyybData/DataDB/ObsSOA_Buoy/DataList.php?RESOURCENAME="+bouy)
    bsobj = BeautifulSoup(html)
    table = bsobj.findAll("table",{"class":"table"})[0]
    rows = table.findAll("tr")

    csvFile = open("/disk/v092.yhuangci/lzhenn/1911-COAWST/obv/bouy/"+bouy+'.csv', 'wt', newline='',encoding='utf-8')

    writer = csv.writer(csvFile)
    try:
        # 遍历
        for row in rows:
            # 创建一个空列表
            csvRow = []
            # 'td'一行中的列，
            for cell in row.findAll(['td', 'th']):
                # 利用函数get_text()获取-添加
                csvRow.append(cell.get_text())
                # 写入
            writer.writerow(csvRow)
    finally:
        csvFile.close()

