import pandas as pd

#Util
def load_fromLocal(data_file):        
    data = pd.read_csv(data_file)    
    return data
    
def load_fromUrl(url):   
    data = pd.read_csv(url, parse_dates=[0])
    return data    

def backup_data(train, test):
    # Make a copy of the data
    train_orig = train.copy()
    test_orig = test.copy()
    return train_orig, test_orig

if __name__=="__main__":
	train_url = "https://raw.githubusercontent.com/agconti/kaggle-titanic/master/data/train.csv"
	test_url ="https://raw.githubusercontent.com/agconti/kaggle-titanic/master/data/test.csv"

	# Load Data
	train_data = load_fromUrl (train_url)
	test_data  = load_fromUrl (test_url)