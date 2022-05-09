# -*- coding:utf-8 -*-
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime
from test_stationarity import test_stationarity 
from sklearn import linear_model
plt.style.use('presentation')

daily_flow_head = ['date', 'flow']
daily_flow_a = pd.Series.from_csv('../data/daily-flow-full-record/flow/daily-flow-A', parse_dates=True)

fc_daily_flow_a=daily_flow_a[datetime(2014,1,1):]
flow_a_all_median = fc_daily_flow_a.median()
flow_a_all_mean = fc_daily_flow_a.mean()
fc_weekly_flow_a=fc_daily_flow_a.resample('W-MON', closed='left',label='left').median()
X_line = range(len(fc_weekly_flow_a))

X_parameter = []
Y_parameter = []
for single_idx, single_flow in zip(X_line[:], fc_weekly_flow_a[:]):
    Y_parameter.append(single_flow)
    X_parameter.append([single_idx])

regr = linear_model.LinearRegression()
regr.fit(X_parameter,Y_parameter)
pr_weekly_flow = pd.Series(regr.predict(X_parameter), index=fc_weekly_flow_a.index)
pr_weekly_flow_daily_fill = pr_weekly_flow.resample('D').ffill()
fc_daily_flow_a = fc_daily_flow_a - pr_weekly_flow_daily_fill
fc_daily_flow_a = fc_daily_flow_a[datetime(2014,1,1):].fillna(method='ffill')
fc_qt_all = fc_daily_flow_a.groupby(lambda x: x.quarter).median()

fc_daily_flow_a['20140101':'20140331'] = fc_daily_flow_a['20140101':'20140331']-fc_qt_all.values[0]
fc_daily_flow_a['20140401':'20140630'] = fc_daily_flow_a['20140401':'20140630']-fc_qt_all.values[1]
fc_daily_flow_a['20140701':'20140930'] = fc_daily_flow_a['20140701':'20140930']-fc_qt_all.values[2]
fc_daily_flow_a['20141001':'20141231'] = fc_daily_flow_a['20141001':'20141231']-fc_qt_all.values[3]
fc_daily_flow_a['20150101':'20150331'] = fc_daily_flow_a['20150101':'20150331']-fc_qt_all.values[0]
fc_daily_flow_a['20150401':'20150630'] = fc_daily_flow_a['20150401':'20150630']-fc_qt_all.values[1]
fc_daily_flow_a['20150701':'20150930'] = fc_daily_flow_a['20150701':'20150930']-fc_qt_all.values[2]
fc_daily_flow_a['20151001':'20151231'] = fc_daily_flow_a['20151001':'20151231']-fc_qt_all.values[3]
fc_daily_flow_a['20160101':'20160331'] = fc_daily_flow_a['20160101':'20160331']-fc_qt_all.values[0]

plt.plot(fc_daily_flow_a)
plt.title('Detrended Non-seasonal Daily Flow')
plt.show()
'''
#bar_ind = (np.arange(len(dtr_monthly_median))+1)*2
bar_ind = (np.arange(len(fc_qt_all)))
print bar_ind
bar_width=0.5
plt.bar(bar_ind,fc_qt_all/flow_a_all_median,bar_width,color='b')
#plt.bar(bar_ind+2*bar_width+0.1,(dtr_monthly_mean)/flow_a_all_mean,color='r', label='Mean')


plt.xlabel('Quarter')
plt.ylabel('Quarterly Customer Flow Index')
#plt.xticks(bar_ind + bar_width+0.1, ('01/14', '02/14', '03/14', '04/14', '05/14','06/14','07/14','08/14','09/14','10/14','11/14','12/14','01/15','02/15','03/15','04/15','05/15','06/15','07/15','08/15','09/15','10/15','11/15','12/15'))
plt.xticks(bar_ind + bar_width/2, ('Q1', 'Q2', 'Q3', 'Q4'))
plt.yticks(np.arange(-0.1, 0.25, 0.05), ('90%','95%','100%','105%','110%','115%','120%','125%','130%'))
plt.title('Quarterly Median Customer Flow Index')
plt.legend()
plt.show()
'''
