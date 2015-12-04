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

#' @title TensorFlow DNN Classifier
#' @name TensorFlow DNN Classifier
#' @description Deep Neural Network classifier
#' @param hidden_units A vector of the number of hidden units in each layer
#' @param n_classes The number of classes in the target
#' @param ... Additional parameters such as keep_prob, a list can be found here: https://github.com/google/skflow/blob/master/skflow/ops/dnn_ops.py
TensorFlowDNNClassifier <- function(hidden_units, n_classes, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowDNNClassifier(",
         createArgs(c("hidden_units", "n_classes")),
         additionalArgs(theDots),
         ")\n"))
}


#' @title TensorFlow DNN Regressor
#' @name TensorFlow DNN Regressor
#' @description Deep Neural Network regressor
#' @param hidden_units A vector of the number of hidden units in each layer
#' @param ... Additional parameters such as keep_prob. A list can be found here: https://github.com/google/skflow/blob/master/skflow/ops/dnn_ops.py
TensorFlowDNNRegressor <- function(hidden_units, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowDNNRegressor(",
             createArgs(c("hidden_units")),
             additionalArgs(theDots),
             ")\n"))
}


#' @title TensorFlow Custom Model Builder
#' @name TensorFlow Custom Model Builder
#' @description This function is used when a custom model is written. 
#' Any custom model will be passed automatically into this function. 
#' @param n_classes The number of classes for the target variable
#' @param ... Additional parameters including batch_size, steps, learning_rate, etc. A list can be found here: https://github.com/google/skflow/blob/master/skflow/__init__.py#L29
TensorFlowEstimator <- function(n_classes, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowEstimator(model_fn=custom_model,",
             createArgs(c("n_classes")),
             additionalArgs(theDots),
             ")\n"))
}


#' @title Convolutionary Neural Network Model
#' @name Convolutionary Neural Network Model
#' @description This function builds convolutionary neural network model with many tunable parameters
#' @param n_filters Number of filters
#' @param filter_shape A vector of integers representing the shape of filters
#' @param activ_func The activation function, e.g. logistic_regression, linear_regression
#' @param transform_method The transformation method used, a list of methods can be found on TensorFlow API doc
#' @param pool_method Pooling method. A list can be found on API doc
#' @param reduction_indices A vector of reduction indices used in pooling
#' @param shape The shape parameter passed to tf.reshape. See API doc.
#' @param ... Additional parameters can be passed, such as strides, see a list here: https://github.com/google/skflow/blob/master/skflow/ops/conv_ops.py
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


#' @title Preparing predictors
#' @name Preparing predictors
#' @param predictors A data.frame/data.table following R's convention 
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


#' @title Preparing target variable
#' @name Preparing target variable
#' @param target A data.frame/data.table following R's convention
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


# internal function used to split training and testing data in the rflow pipeline
trainTestSplit <- function(test_percent=0.25){

  cat(sprintf('
X_train, X_test, y_train, y_test = train_test_split( \
X, y, test_size=%f, random_state=50)
', test_percent))

}

# internal function to fit the model
fit <- function(){
  cat("model.fit(X_train, y_train)\n")
}

# internal function to predict on testing set
predict <- function(save = F){
  cat("predictions = model.predict(X_test)\n")
  if(save){savePyObjToFile('predictions')}
}


#' @title rflow Pipeline
#' @name rflow Pipeline
#' @description Main function used to run TensorFlow in pipeline. See demos for usage
#' @param eval_metric Evaluation metric to be used, e.g. accuracy_score, mean_squared_error. A list can be found here: http://scikit-learn.org/stable/modules/classes.html#sklearn-metrics-metrics
#' @param ... Additional transformations can be passed here, such as custom model. See demos
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


#' @title Prepare Text Data
#' @name Prepare Text Data
#' @description This function loads/prepares data for text classification
#' @param fileName Path to the data
#' @param dataType Whether this is 'train' or 'test' data
#' @param targetColInd The column index of the target variable (labels)
#' @param predictorColInd The column index of the predictor (text)
#' @param delimiter The delimiter used to parse the data
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
# Abstract more methods
# Enable customized test set without using splitting method
# Text classification
# Borrow some interface usage for caret/sklearn

