#  Copyright 2015 Yuan Tang
#  Copyright 2015 Google Inc. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.


require(rPython)

importDeps <- function(){
cat("
from pandas import DataFrame
import os
import random
from sklearn import metrics
from sklearn.cross_validation import train_test_split
import skflow
from numpy import asarray, ndarray
import numpy as np
import sys
from json import dumps
import tensorflow as tf
")
}

importConstants <- function(){
cat("
true = True
false = False
")
}


TensorFlowDNNClassifier <- function(hidden_units, n_classes, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowDNNClassifier(",
         createArgs(c("hidden_units", "n_classes")),
         additionalArgs(theDots),
         ")\n"))
}

TensorFlowDNNRegressor <- function(hidden_units, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowDNNRegressor(",
             createArgs(c("hidden_units")),
             additionalArgs(theDots),
             ")\n"))
}

TensorFlowEstimator <- function(n_classes, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowEstimator(model_fn=custom_model,",
             createArgs(c("n_classes")),
             additionalArgs(theDots),
             ")\n"))
}

ConvModel <- function(n_filters = 12, filter_shape = c(3, 3),
                      activ_func='logistic_regression',
                      transform_method = 'tf.expand_dims',
                      pool_method = 'tf.reduce_max', reduction_indices = c(1, 2),
                      shape = c(-1, 12),
                      ...){
  customModelWriter(
    funcInput = c('X', 'y'),
    returnValue = TensorActivator(activ_func),
    TensorTransformer(transform_method, 3),
    TensorOperator('conv2d', n_filters = n_filters, filter_shape = filter_shape, ...),
    TensorTransformer(pool_method, reduction_indices),
    TensorTransformer('tf.reshape', shape))
}

preparePredictors <- function(predictors){
  python.assign("X", predictors)
  python.exec('
  from pandas import DataFrame
  from numpy import asarray
  from json import dumps
  X_df = DataFrame(X)
  X_lists = X_df.values.tolist()
  f = open("X_lists.txt", "w")
  f.write(dumps(X_lists))
  f.close()')
  X_lists <- suppressWarnings(readLines("X_lists.txt"))

  dtype <<- 'float64'

  cat(paste0("X = asarray(",
         X_lists, ", ",
         createArgs('dtype'),
         ")\n"))

  unlink("X_lists.txt")
}

prepareTargetVar <- function(target){
  # deal with factor target
  if(is.factor(target)){
    python.assign("y", as.integer(as.factor(target))-1) # starts from 0
    dtype <<- 'int64'
  } else {
    python.assign("y", target)
    dtype <<- 'float64'
  }

  python.exec('
  from numpy import asarray
  from json import dumps
  f = open("y_lists.txt", "w")
  f.write(dumps(y))
  f.close()')
  y_lists <- suppressWarnings(readLines("y_lists.txt"))

  cat(paste0("y = asarray(",
         y_lists, ", ",
         createArgs('dtype'),
         ")\n"))

  unlink("y_lists.txt")
}

trainTestSplit <- function(test_percent=0.25){

  cat(sprintf('
X_train, X_test, y_train, y_test = train_test_split( \
X, y, test_size=%f, random_state=50)
', test_percent))

}

fit <- function(){
  cat("model.fit(X_train, y_train)\n")
}

predict <- function(save = F){
  cat("predictions = model.predict(X_test)\n")
  if(save){savePyObjToFile('predictions')}
}

rflowPipeline <- function(eval_metric, test_percent, ...){

  sink("test.py")
  importDeps()
  importConstants()
  theDots <- list(...) # execute
  # only split when test_percent is not null
  if(!is.null(test_percent)){
    trainTestSplit(test_percent)
  }
  fit()
  predict()
  evalFunc(eval_metric)
  sink()

  system("python test.py")
}

## evaluation metrics
# e.g. accuracy_score, mean_squared_error, etc (more here: http://scikit-learn.org/stable/modules/classes.html#sklearn-metrics-metrics)
evalFunc <- function(eval_metric){
  cat(sprintf('
score = metrics.%s(predictions, y_test)
print("Evaluation Score: " + str(score))
      ', eval_metric))
}

# used for quick testing
loadMINST <- function(){
  cat(
'
from sklearn import datasets
digits = datasets.load_digits()
X = digits.images
y = digits.target
'
  )
}

prepareTextData <- function(fileName,
                            dataType = 'train',
                            targetColInd = 0,
                            predictorColInd = 2,
                            delimiter = ','){
  cat(
    sprintf(
'
import csv
target = []
data = []
reader = csv.reader(open(\"%s\"), delimiter=\"%s\")
for line in reader:
  target.append(int(line[%d]))
  data.append(line[%d])
X_%s, y_%s = data, np.array(target, np.float32)
' , fileName, delimiter, targetColInd, predictorColInd, dataType, dataType))
  
}

# TODOs:
# Refactoring
# Enable customized test set without using splitting method
# Text classification
# Borrow some interface usage for caret/sklearn

