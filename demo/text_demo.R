# dbpedia dataset can be downloaded from: 
# https://drive.google.com/folderview?id=0Bz8a_Dbh9Qhbfll6bVpmNUtUcFdjYmF2SEpmZUZUcVNiMUw1TWN6RDV3a0JHT3kxLVhVR2M

library(data.table)
X_train <- fread('dbpedia_csv/train.csv', select = 3)
y_train <- fread('dbpedia_csv/train.csv', select = 1)
X_test <- fread('dbpedia_csv/test.csv', select = 3)
y_test <- fread('dbpedia_csv/test.csv', select = 1)


sink('test.py')
prepareTextData('dbpedia_csv/train.csv', dataType = 'train')
prepareTextData('dbpedia_csv/test.csv', dataType = 'test')

sink()
