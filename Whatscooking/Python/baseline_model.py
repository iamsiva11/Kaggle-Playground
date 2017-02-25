"""
Logisticregression - Score: 0.78862
"""

import pandas as pd
import numpy as np
import nltk
import re
from nltk.stem import WordNetLemmatizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn import grid_search


def data_backup(train, test):
    train_bkp = train.copy()
    test_bkp  = test.copy()
    return train_bkp,test_bkp

def preprocess_string(data):
    data['ingredients_string'] =  [' '.join([WordNetLemmatizer().lemmatize(
                                    re.sub('[^A-Za-z]', ' ', line))\
                                    for line in lists]).strip()\
                                    for lists in data['ingredients']]
    return data

#Vectorise , tfidf
def vectorise_dataset(train_dataset,test_dataset):
    #train
    corpustr = train_dataset['ingredients_string']
    vectorizertr = TfidfVectorizer(stop_words='english',\
                                 ngram_range = ( 1 , 1 ),analyzer="word", \
                                 max_df = .57 , binary=False , token_pattern=r'\w+' , sublinear_tf=False)
    tfidf_train = vectorizertr.fit_transform(corpustr).todense()
    #test
    corpusts = test_dataset['ingredients_string']
    tfidf_test = vectorizertr.transform(corpusts)    
    return tfidf_train,tfidf_test

def logit_classifier():
    parameters = {'C':[1, 10]}
    clf = LogisticRegression()
    classifier = grid_search.GridSearchCV(clf, parameters)
    classifier = classifier.fit(X_train, Y_train)
    return classifier

def make_predictions(classifier, X_test):
    predictions=classifier.predict(X_test)
    return predictions

def submit():
    test_dataset['cuisine'] = pred
    new_submit = pd.DataFrame( {'id':test_dataset['id'] , 'cuisine':test_dataset['cuisine'] })
    new_submit.to_csv("submit_1_logit.csv",index=False)


if __name=="__main__":
	# Load Data
	train_dataset = pd.read_json("Data/train.json")
	test_dataset = pd.read_json("Data/test.json")
	train_bkp, test_bkp = data_backup(train_dataset, test_dataset)
	# Preprocess 
	train_dataset = preprocess_string(train_dataset)
	test_dataset = preprocess_string(test_dataset)
	# tfidf 
	X_train, X_test = vectorise_dataset(train_dataset, test_dataset)
	Y_train = train_dataset['cuisine']
	# Make Prediction
	pred = make_predictions( logit_classifier() , X_test)
	# Make submission
	submit()