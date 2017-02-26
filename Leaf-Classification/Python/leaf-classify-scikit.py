import numpy as np
import pandas as pd

#Sklearn imports
from sklearn.preprocessing import StandardScaler
from sklearn.cross_validation import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.linear_model import LogisticRegression
from sklearn.grid_search import GridSearchCV

def data_backup(train, test):
    train_bkp = train.copy()
    test_bkp  = test.copy()
    return train_bkp, test_bkp

# Data Standardisation
def data_standardise(data):
	scaler = StandardScaler().fit(data)
	data = scaler.transform(data)
	return scaler, data

#Label encode the target values
def encode(train_dataset):
    # Encode target varibles
    le = LabelEncoder().fit(train_dataset.species)
    labels = le.transform(train_dataset.species)
    classes = list(le.classes_) # save column names for submission
    return labels, classes

def LogisticRegression_classifier(X_train, Y_train):
	# Logit
	params = {'C':[1, 10, 50, 100, 500, 1000, 2000], 'tol': [0.001, 0.0001, 0.005]}
	log_reg = LogisticRegression(solver='lbfgs', multi_class='multinomial')
	clf = GridSearchCV(log_reg, params, scoring='log_loss', refit='True', n_jobs=1, cv=5)
	clf.fit(X_train, train_labels)
	return clf

def LDA_classifier(X_train, Y_train):	
	#LDA
	clf = LinearDiscriminantAnalysis( solver = "svd", n_components=1 )
	#clf.get_params().keys()
	clf.fit(X_train, train_labels)
	return clf

def make_predictions(classifier, X_test):
	predictions = clf.predict_proba(X_Test)
	return predictions

def make_submission(predictions, classes , test_ids,  file_name):
	#submission = pd.DataFrame(predictions, columns = classes)
	#submission.insert(0, 'id', test_ids)
	#submission.reset_index()	
	# Format DataFrame
	submission = pd.DataFrame(predictions, index=test_ids, columns=classes)
	# Export Submission
	submission.to_csv(file_name, index = False)	


if __name__=="__main__":
	# Load Data
	train_dataset = pd.read_csv("leaf-train.csv")
	test_dataset = pd.read_csv("leaf-test.csv")
	# Always a good practice to keep a backup of the training and test data
	train_bkp, test_bkp = data_backup(train_dataset, test_dataset)	
	# Data Preprocessing 
	# Preapre train data
	X_train = train_dataset.drop(['id','species'], axis=1).values
	scaler, X_train = data_standardise(X_train)
	train_labels, train_classes = encode(train_dataset)
	# Preapre test data
	test_ids = test_dataset.pop('id') #Id column for submission file
	X_Test = test_dataset.values # Need data in array format
	X_Test = scaler.transform(X_Test)
	# Train the Models
	logit_clf = LogisticRegression_classifier(X_train, train_labels)
	lda_clf = LDA_classifier(X_train, train_labels)	
	# Make Prediction
	pred = make_predictions(logit_clf, X_test)
	# Make Submission
	make_submission(pred, train_classes , test_ids ,"submission-file_1.csv")