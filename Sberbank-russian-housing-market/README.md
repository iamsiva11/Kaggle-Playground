# Sberbank russian housing market

![Competition Image](http://wx1.sinaimg.cn/mw690/5396ee05ly1ff33zmo48zj21he12ghdt.jpg)

> Type of problem - Regression.

## Why - the big picture.
Although the housing market is relatively stable in Russia, the country’s volatile economy makes forecasting prices as a function of apartment characteristics a unique challenge. 

Complex interactions between housing features such as number of bedrooms and location are enough to make pricing predictions complicated. Adding an unstable economy to the mix means Sberbank and their customers need more than simple regression models in their arsenal.

An accurate forecasting model will allow Sberbank to provide more certainty to their customers in an uncertain economy.

## About the competition 

The aim of this competition is to predict the sale price of each property. 

In this competition, Sberbank is challenging Kagglers to develop algorithms which use a broad spectrum of features to predict realty prices. Competitors will rely on a rich dataset that includes housing data and macroeconomic patterns. 

## Dataset

The training data is from August 2011 to June 2015, and the test set is from July 2015 to May 2016. 


The target variable is called *price_doc* in train.csv.

- *train.csv, test.csv:* information about individual transactions. The rows are indexed by the "id" field, which refers to individual transactions (particular properties might appear more than once, in separate transactions). These files also include supplementary information about the local area of each property.

- *macro.csv:* data on Russia's macroeconomy and financial sector (could be joined to the train and test sets on the "timestamp" column)

The dataset also includes information about overall conditions in Russia's economy and finance sector, so you can focus on generating accurate price forecasts for individual properties, without needing to second-guess what the business cycle will do.