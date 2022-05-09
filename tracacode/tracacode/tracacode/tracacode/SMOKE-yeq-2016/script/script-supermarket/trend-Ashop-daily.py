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

X_line = range(len(fc_daily_flow_a))

X_parameter = []
Y_parameter = []
for single_idx, single_flow in zip(X_line[:], fc_daily_flow_a[:]):
    Y_parameter.append(single_flow)
    X_parameter.append([single_idx])

regr = linear_model.LinearRegression()
regr.fit(X_parameter,Y_parameter)

plt.scatter(X_parameter,Y_parameter)
plt.plot(X_parameter,regr.predict(X_parameter),linewidth=3)

regr.fit(X_parameter[20:],Y_parameter[20:])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[40:],Y_parameter[40:])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[60:],Y_parameter[60:])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[80:],Y_parameter[80:])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[:-20],Y_parameter[:-20])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[:-40],Y_parameter[:-40])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[:-60],Y_parameter[:-60])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[:-80],Y_parameter[:-80])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[20:-20],Y_parameter[20:-20])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[40:-40],Y_parameter[40:-40])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)
regr.fit(X_parameter[60:-60],Y_parameter[60:-60])
print regr.predict(0)-regr.predict(365)
plt.plot(X_parameter,regr.predict(X_parameter),'r-',alpha=0.8,linewidth=1)

#print daily_flow
#lineplot_a = plt.plot(fc_daily_flow_a,'r-', linewidth=2.0, alpha=0.8, label="JiHua")

plt.xlabel('Day Index')
plt.ylabel('Customer Flow')
plt.title('Daily Customer Flow')
plt.show()
