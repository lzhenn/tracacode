#! /usr/bin/env python
#  Deal with 59287 station data 
#   
#               L_Zealot
#               Jul 17, 2019
#               Guangzhou, GD
#

import math
import os
import numpy as np
import pandas as pd
import datetime

import matplotlib
matplotlib.use('Agg') 
import matplotlib.pylab as plt
from matplotlib.pyplot import savefig

from keras.models import Sequential
from keras.layers import Dense
from keras.layers import LSTM
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error

# fix random seed for reproducibility
np.random.seed(7)


#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Station Number
    sta_num='59287'

    # Input File
    in_dir='/home/lzhenn/array2/lzhenn/station/post/'

    # Start Year 
    start_years=[1957, 1996, 2011]
    
    # End Year
    end_year=2018

    # Var Name 
    var_name='TEM' 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    pt=pd.read_csv(in_dir+sta_num+var_name+'.txt', sep='\s+', header=None, names=['station', 'lat', 'lon', 'alt', 'year', 'mon', 'day', 'avg_temp', 'max_temp', 'min_temp', 'avg_code', 'max_code', 'min_code'])
    sample_pt=pt[pt.year >= start_years[0]]
    sample_pt0=sample_pt[sample_pt.year < start_years[1]]
    sample_pt1=sample_pt[sample_pt.year >= start_years[1]]
    sample_pt1=sample_pt1[sample_pt1.year < start_years[2]]
    sample_pt2=sample_pt[sample_pt.year >= start_years[2]]
    df0=combine_mon_anom(sample_pt0, sample_pt1, sample_pt2)
    dataset = df0['avg_temp'].values.reshape(-1,1)*0.1
    
    print(dataset)
    
    # normalize the dataset
    scaler = MinMaxScaler(feature_range=(0, 1))
    dataset = scaler.fit_transform(dataset)

    # split into train and test sets
    train_size = int(len(dataset) * 0.67)
    test_size = len(dataset) - train_size
    train, test = dataset[0:train_size,:], dataset[train_size:len(dataset),:]  

    # use this function to prepare the train and test datasets for modeling
    look_back = 1 
    trainX, trainY = create_dataset(train, look_back)
    testX, testY = create_dataset(test, look_back)

    # reshape input to be [samples, time steps, features]
    trainX = np.reshape(trainX, (trainX.shape[0], 1, trainX.shape[1]))
    testX = np.reshape(testX, (testX.shape[0], 1, testX.shape[1]))

    # create and fit the LSTM network
    model = Sequential()
    model.add(LSTM(4, input_shape=(1, look_back)))
    model.add(Dense(1))
    model.compile(loss='mean_squared_error', optimizer='adam')
    model.fit(trainX, trainY, epochs=10, batch_size=1, verbose=2)
   
    # make predictions
    trainPredict = model.predict(trainX)
    testPredict = model.predict(testX)
    
    # invert predictions
    trainPredict = scaler.inverse_transform(trainPredict)
    trainY = scaler.inverse_transform([trainY])
    testPredict = scaler.inverse_transform(testPredict)
    testY = scaler.inverse_transform([testY])
    trainScore = math.sqrt(mean_squared_error(trainY[0], trainPredict[:,0]))
    print('Train Score: %.2f RMSE' % (trainScore))
    testScore = math.sqrt(mean_squared_error(testY[0], testPredict[:,0]))
    print('Test Score: %.2f RMSE' % (testScore))
    
    # shift train predictions for plotting
    trainPredictPlot = np.empty_like(dataset)
    trainPredictPlot[:, :] = np.nan
    trainPredictPlot[look_back:len(trainPredict)+look_back, :] = trainPredict

    # shift test predictions for plotting
    testPredictPlot = np.empty_like(dataset)
    testPredictPlot[:, :] = np.nan
    testPredictPlot[len(trainPredict)+(look_back*2)+1:len(dataset)-1, :] = testPredict

    # plot baseline and predictions
    obv=scaler.inverse_transform(dataset)
    plt.plot(obv[-60:])
#    plt.plot(trainPredictPlot)
    plt.plot(testPredictPlot[-60:])
    plt.legend(['obs','fcst'], loc='best', ncol=2 )
    plt.show()
    savefig('../fig/test.png')

def combine_mon_anom(*args):
    df=pd.DataFrame()
    for item in args:
        df_temp=reform_df(item)    
        df_temp=df_temp.resample('M').mean()
        df_temp=df_temp.to_period()
        df_anom, df_season=dcomp_seasonality(df_temp)
        df=pd.concat([df, df_anom])
    return df

def reform_df(pt):
    start_time=str(pt.iloc[0]['year'])+'-'+str(pt.iloc[0]['mon'])+'-'+str(pt.iloc[0]['day'])
    end_time=str(pt.iloc[-1]['year'])+'-'+str(pt.iloc[-1]['mon'])+'-'+str(pt.iloc[-1]['day'])
    date_range = pd.date_range(start=start_time, end=end_time)
    df =pd.DataFrame(pt.loc[:,['avg_temp', 'max_temp', 'min_temp']].values, index=date_range, columns=['avg_temp', 'max_temp', 'min_temp'])
    return df

def dcomp_seasonality(df):
    df_season = df.groupby(df.index.month).mean() # climatological seasonal cycle
    df = df.groupby(df.index.month).transform(lambda x: x-x.mean()) # calculate monthly anomaly
    return df, df_season

# X is the number of passengers at a given time (t) and Y is the number of passengers at the next time (t + 1).

# convert an array of values into a dataset matrix
def create_dataset(dataset, look_back=1):
    dataX, dataY = [], []
    for i in range(len(dataset)-look_back-1):
        a = dataset[i:(i+look_back), 0]
        dataX.append(a)
        dataY.append(dataset[i + look_back, 0])
    return np.array(dataX), np.array(dataY)




if __name__ == "__main__":
    main()




