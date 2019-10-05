#! /usr/bin/env python
#  Deal with 59287 station data 
#   
#               L_Zealot
#               Jul 17, 2019
#               Guangzhou, GD
#

import os
import json
import numpy as np
import pandas as pd
import datetime


#-------------------------------------
# Function Definition Part
#-------------------------------------
def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Result Input File
    result_in_file='../testdata/result_08-16.json'

    # South China Input
    sta_file='../testdata/south_china_station.csv'


    # Out File
    out_file='../testdata/south_china_result.csv'

    # Least Start Year 
    start_year=1979
    
    # End Year
    end_year=2016

    # Var Name 
    var_name='TEM' 

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    sta_pt=pd.read_csv(sta_file,  index_col=0)
    with open(result_in_file) as f:
        result_dic=json.load(f)
    sta_pt=sta_pt.loc[:,['lat','lon','alt']]
    sta_pt['sign_score']=np.nan
    for key, value in result_dic.items():
        try:
            sta_pt.at[int(key),'sign_score']=value['sign_score']
        except:
            print(key, ' not exist!')
            continue
    print(sta_pt)
    sta_pt.to_csv(out_file, sep=' ')
    exit()
    for idx in pt[pt['province'].isin(region_list)].index:
        print(idx)
        content=os.popen('grep ' + str(idx) + ' ' + raw_in_dir+var_name+'/*')
        with open(post_our_dir+str(idx)+var_name+'.txt','w') as f:
            f.write(content.read())
    exit()
    sample_pt=pt[pt.year >= start_year]
    df0=reform_df(sample_pt)
    df0, df0_season= dcomp_seasonality(df0)
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
    plt.plot(obv[:])
    plt.plot(trainPredictPlot[:])
    plt.plot(testPredictPlot[:])
    plt.legend(['obs','train_fcst','test_fcst'], loc='best', ncol=2 )
    plt.show()
    savefig('../fig/test.png')
    

def reform_df(pt):
    start_time=str(pt.iloc[0]['year'])+'-'+str(pt.iloc[0]['mon'])+'-'+str(pt.iloc[0]['day'])
    end_time=str(pt.iloc[-1]['year'])+'-'+str(pt.iloc[-1]['mon'])+'-'+str(pt.iloc[-1]['day'])
    date_range = pd.date_range(start=start_time, end=end_time)
    series=pd.Series(pt['mon'].values*100+pt['day'].values, name='aux', index=pt.index)
    pt=pd.concat([pt, series], axis=1)
    df =pd.DataFrame(pt.loc[:,['avg_temp', 'max_temp', 'min_temp', 'aux']].values, index=date_range, columns=['avg_temp', 'max_temp', 'min_temp', 'aux'])
    return df

def dcomp_seasonality(df):
    df_season=df.groupby('aux').mean()
    df = df.groupby('aux').transform(lambda x: x-x.mean())
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




