# Classification of Text Documents (WIP)

# dbpedia dataset can be downloaded from: 
# https://drive.google.com/folderview?id=0Bz8a_Dbh9Qhbfll6bVpmNUtUcFdjYmF2SEpmZUZUcVNiMUw1TWN6RDV3a0JHT3kxLVhVR2M

# # Do some data manipulation in R
# library(data.table)
# X_train <- fread('dbpedia_csv/train.csv', select = 3)
# y_train <- fread('dbpedia_csv/train.csv', select = 1)
# X_test <- fread('dbpedia_csv/test.csv', select = 3)
# y_test <- fread('dbpedia_csv/test.csv', select = 1)

# rflowPipeline(eval_metric = 'accuracy_score',
#               test_percent = 0.25,
#               prepareTextData('dbpedia_csv/train.csv', dataType = 'train'),
#               prepareTextData('dbpedia_csv/test.csv', dataType = 'test'),
#               TensorProcessor(name='VocabularyProcessor',  max_document_length = 10),
#               TensorProcessor.transform('train'),
#               TensorProcessor.transform('test'),
#               customModelWriter(
#                 funcInput = c('X', 'y'),
#                 returnValue = TensorActivator('logistic_regression'),
#                 # TODO: design where to return n_words as n_classes, TensorProcessor.transform OR in insertPyObjsStr
#                 TensorOperator('categorical_variable', n_classes=743040, 
#                                embedding_size=50, name='words'),
#                 TensorTransformer('tf.reduce_max', reduction_indices = 1)),
#               TensorFlowEstimator(n_classes = 15, steps=650, optimizer='Adam', # BUG: optimizer not found
#                                   learning_rate=0.012, continue_training=T)) # TODO: differentiate two n_classes
#               