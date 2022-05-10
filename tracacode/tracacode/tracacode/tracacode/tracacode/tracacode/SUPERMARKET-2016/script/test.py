import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime


daily_flow_head = ['date', 'flow']
daily_flow = pd.Series.from_csv('../data/daily-flow-full-record/uniq/daily-flow-D', parse_dates=True)
#print daily_flow
plt.plot(daily_flow,'k-')
plt.show()
