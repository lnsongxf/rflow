# Classification of Text Documents (WIP)

# dbpedia dataset can be downloaded from: 
# https://drive.google.com/folderview?id=0Bz8a_Dbh9Qhbfll6bVpmNUtUcFdjYmF2SEpmZUZUcVNiMUw1TWN6RDV3a0JHT3kxLVhVR2M
# with columns: 1. labels; 2. titles; 3. text

# # Do some data manipulation in R and then save them
# library(data.table)
# X_train <- fread('dbpedia_csv/train.csv', select = 3)
# y_train <- fread('dbpedia_csv/train.csv', select = 1)
# X_test <- fread('dbpedia_csv/test.csv', select = 3)
# y_test <- fread('dbpedia_csv/test.csv', select = 1)
# ...

# parameters sepecified in TensorFlowEstimator must be intialized here first
n_classes <- 15
steps <- 100
optimizer <- 'Adam'
learning_rate <- 0.012
continue_training <- T

rflowPipeline(eval_metric = 'accuracy_score',
              test_percent = NULL, # no train/test split is needed
              prepareTextData('dbpedia_csv/train.csv', dataType = 'train'),
              prepareTextData('dbpedia_csv/test.csv', dataType = 'test'),
              TensorProcessor('VocabularyProcessor',  max_document_length = 10),
              TensorProcessor.transform('train'),
              TensorProcessor.transform('test'),
              customModelWriter(
                funcInput = c('X', 'y'),
                returnValue = TensorActivator('logistic_regression'),
                # TODO: design where to return n_words as n_classes, TensorProcessor.transform OR in insertPyObjsStr
                TensorOperator('categorical_variable', n_classes=743040, 
                               embedding_size=50, name='words'),
                TensorTransformer('tf.reduce_max', reduction_indices = 1)),
              TensorFlowEstimator(n_classes=n_classes, steps=steps, optimizer=optimizer,
                                  learning_rate=learning_rate, continue_training=continue_training))
            
# TODO: continue_training
# TODO: log progress for TensorProcessor, transform, etc

