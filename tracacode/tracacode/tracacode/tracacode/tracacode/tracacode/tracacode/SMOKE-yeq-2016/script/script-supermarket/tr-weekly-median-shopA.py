# -*- coding:utf-8 -*-
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime
from test_stationarity import test_stationarity 
from sklearn import linear_model
plt.style.use('presentation')

# Define function for linear model
def leaner(flow):
    X_line = range(len(flow))
    print X_line
    X_parameter = []
    Y_parameter = []
    for single_idx, single_flow in zip(X_line[:], flow[:]):
        Y_parameter.append(single_flow)
        X_parameter.append([single_idx])

    regr = linear_model.LinearRegression()
    regr.fit(X_parameter,Y_parameter)
    return regr,X_parameter

daily_flow_head = ['date', 'flow']
daily_flow_a = pd.Series.from_csv('../data/daily-flow-full-record/flow/daily-flow-A', parse_dates=True)

fc_daily_flow_a=daily_flow_a[datetime(2014,1,1):]
fc_weekly_flow_a=fc_daily_flow_a.resample('W-MON', closed='left').median()

[regr, X_parameter] = leaner(fc_daily_flow_a)
pr_daily_flow = pd.Series(regr.predict(X_parameter), index=fc_daily_flow_a.index)

[regr, X_parameter] = leaner(fc_weekly_flow_a)
pr_weekly_flow = pd.Series(regr.predict(X_parameter), index=fc_weekly_flow_a.index)
print pr_weekly_flow['20160201']-pr_weekly_flow['20140203']
print pr_daily_flow['20150101']-pr_daily_flow['20140101']

plt.plot(fc_daily_flow_a,'b.',linewidth=1)
plt.plot(fc_weekly_flow_a,'g-')
plt.plot(pr_weekly_flow,'b-',linewidth=3)
plt.plot(pr_daily_flow,'r--',linewidth=3)

#print daily_flow
#lineplot_a = plt.plot(fc_daily_flow_a,'r-', linewidth=2.0, alpha=0.8, label="JiHua")

plt.xlabel('Day Index')
plt.ylabel('Customer Flow')
plt.title('Daily Customer Flow')
plt.show()


