import numpy as np
import pandas as pd

from sklearn.linear_model import LinearRegression


def load_fromLocal(data_file):        
    data = pd.read_csv(data_file)    
    return  data
    
def load_fromUrl(url):   
    data = pd.read_csv(url,parse_dates=[0])
    return  data    

def backup_data(train, test):
    # make a copy of the data
    train_orig = train.copy()
    test_orig = test.copy()
    return train_orig, test_orig
    
# Feature engineering
def reformat_datecolumn(data):
    temp = pd.DatetimeIndex(data['datetime'])
    data['year'] = temp.year
    data['month'] = temp.month
    data['hour'] = temp.hour
    data['weekday'] = temp.weekday
    return data

if __name__ =="__main__":

	# Data Source
	train_url = "https://raw.githubusercontent.com/jesford/bike-sharing/master/train.csv"
	test_url = "https://raw.githubusercontent.com/jesford/bike-sharing/master/test.csv"


	# Load Data
	train_data =  load_fromUrl(train_url)
	test_data =  load_fromUrl(test_url)
	train_orig, test_orig = backup_data(train_data, test_data)

	# Data Preparation
	new_train_data =  reformat_datecolumn(train_data)        
	new_test_data =  reformat_datecolumn(test_data)        

	# So we should transform the target columns into log domain as well.
	for col in ['casual', 'registered', 'count']:
    	new_train_data['log-' + col] = new_train_data[col].apply(lambda x: np.log1p(x))

	# Define features vector
	features = ['season', 'holiday', 'workingday', 'weather',
	            'temp', 'atemp', 'humidity', 'windspeed', 'year',
	             'month', 'weekday', 'hour']

	# Simple Model
	clf = LinearRegression()
	clf.fit(new_train_data[features], new_train_data['log-count'])
	result = clf.predict(new_test_data[features])