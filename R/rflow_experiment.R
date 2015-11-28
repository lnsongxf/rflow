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
import sys
from json import dumps
import tensorflow as tf
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

#' @param ... Additional argument except the tensor input
#' e.g. TensorTransformation('f', 1, c(1,2,3))  => X = tf.f(X, 1, [1, 2, 3])
TensorTransformation <- function(funcName, ...){
  paste0("X = ", funcName, "(X, ",
             insertPyObjsStr(...),
             ")\n")
}

ConvModel <- function(n_filters = 12, filter_shape = c(3, 3),
                      activ_func='logistic_regression',
                      transform_method = 'tf.expand_dims',
                      pool_method = 'tf.reduce_max', reduction_indices = c(1, 2),
                      shape = c(-1, 12),
                      ...){
  funcWriter(
    body = {
      cat(sprintf("\t%s\t%s\t%s\t%s",
        TensorTransformation(transform_method, 3),
        TensorTransformation('skflow.ops.conv2d', n_filters, filter_shape, ...),
        TensorTransformation(pool_method, reduction_indices),
        TensorTransformation('tf.reshape', shape)
      ))},
    funcHeader = "def custom_model(X, y):",
    returnValue = paste0("return skflow.models.", activ_func, "(X, y)"))
}

TensorFlowEstimator <- function(n_classes, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowEstimator(model_fn=custom_model,",
             createArgs(c("n_classes")),
             additionalArgs(theDots),
             ")\n"))
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

predict <- function(save = F){
  cat("predictions = model.predict(X_test)\n")
  if(save){savePyObjToFile('predictions')}
}
fit <- function(){
  cat("model.fit(X_train, y_train)\n")
}

## metrics
accuracyScore <- function(){
  cat('
score = metrics.accuracy_score(predictions, y_test)
print("Accuracy: %f" % score)
      ')
}

meanSquaredError <- function(){
  cat('
score = metrics.mean_squared_error(predictions, y_test)
print("MSE: %f" % score)
  ')
}

# used for quick testing
loadMINST <- function(){
  cat(
'
from sklearn import datasets
digits = datasets.load_digits()
X = digits.images
y = digits.target
')
}

# TODO: different splitting method
# Travis test
# Refactoring
# Enable customized test set without using splitting method
# Text classification


