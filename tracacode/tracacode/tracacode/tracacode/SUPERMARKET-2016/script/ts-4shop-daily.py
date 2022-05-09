# -*- coding:utf-8 -*-
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime
plt.style.use('presentation')

daily_flow_head = ['date', 'flow']
daily_flow_a = pd.Series.from_csv('../data/daily-flow-full-record/uniq/daily-flow-A', parse_dates=True)
daily_flow_b = pd.Series.from_csv('../data/daily-flow-full-record/uniq/daily-flow-B', parse_dates=True)
daily_flow_c = pd.Series.from_csv('../data/daily-flow-full-record/uniq/daily-flow-C', parse_dates=True)
daily_flow_d = pd.Series.from_csv('../data/daily-flow-full-record/uniq/daily-flow-D', parse_dates=True)

#print daily_flow
lineplot_a = plt.plot(daily_flow_a,'b-', linewidth=2.0, alpha=0.8, label="JiHua")
lineplot_b = plt.plot(daily_flow_b,'r-', linewidth=2.0, alpha=0.8, label="WanDa")
lineplot_c = plt.plot(daily_flow_c,'y-', linewidth=2.0, alpha=0.8, label="XinTianDi")
lineplot_d = plt.plot(daily_flow_d,'g-', linewidth=2.0, alpha=0.8, label="XinTangDaDao")
plt.xlabel('Date', fontsize=20)
plt.ylabel('Customer Flow', fontsize=20)
plt.title('Daily Customer Flow', fontsize=22)
plt.legend()
plt.show()
