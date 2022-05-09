# -*- coding:utf-8 -*-
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime
plt.style.use('presentation')

daily_flow_head = ['date', 'flow']
flow_a_daily = pd.Series.from_csv('../data/daily-flow-full-record/flow/daily-flow-A', parse_dates=True)
flow_b_daily = pd.Series.from_csv('../data/daily-flow-full-record/flow/daily-flow-B', parse_dates=True)
flow_c_daily = pd.Series.from_csv('../data/daily-flow-full-record/flow/daily-flow-C', parse_dates=True)
flow_d_daily = pd.Series.from_csv('../data/daily-flow-full-record/flow/daily-flow-D', parse_dates=True)

#process flow
flow_a_weekly=flow_a_daily.resample('W', closed='left', label='medium').mean()
flow_b_weekly=flow_b_daily.resample('W', closed='left', label='medium').mean()
flow_c_weekly=flow_c_daily.resample('W', closed='left', label='medium').mean()
flow_d_weekly=flow_d_daily.resample('W', closed='left', label='medium').mean()

#plot daily_flow
lineplot_a = plt.plot(flow_a_daily,'k-', linewidth=1.0, alpha=0.5)
lineplot_b = plt.plot(flow_b_daily,'r-', linewidth=1.0, alpha=0.5)
lineplot_c = plt.plot(flow_c_daily,'b-', linewidth=1.0, alpha=0.5)
lineplot_d = plt.plot(flow_d_daily,'g-', linewidth=1.0, alpha=0.5)

#plot weekly flow
lineplot_a = plt.plot(flow_a_weekly,'k-', linewidth=3.0, alpha=0.8, label="JiHua")        
lineplot_b = plt.plot(flow_b_weekly,'r-', linewidth=3.0, alpha=0.8, label="WanDa")        
lineplot_c = plt.plot(flow_c_weekly,'b-', linewidth=3.0, alpha=0.8, label="XinTianDi")    
lineplot_d = plt.plot(flow_d_weekly,'g-', linewidth=3.0, alpha=0.8, label="XinTangDaDao") 

plt.xlabel('Date')
plt.ylabel('Customer Flow')
plt.title('Daily/Weekly Customer Flow')
plt.legend()
plt.show()
