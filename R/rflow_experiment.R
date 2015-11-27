require(rPython)

importDeps <- function(){
cat("
from pandas import DataFrame
import os
import random
from sklearn import metrics
from sklearn.cross_validation import train_test_split
import skflow
from numpy import asarray
import sys
import json
import tensorflow as tf
")
}

createArgs <- function(names, getFunc=get){
  if(length(names) == 0) return(NULL)
  if(is.list(names)){names <- names(names)} # deal with additional arguments
  paste(unlist(lapply(names, function(name){
    RHS <- toPyObjStr(getFunc(name))
    paste0(name, "=", RHS)
  })), collapse = ", ")
}

# c(1,2,3) => [1,2,3]
toPyObjStr <- function(rObj){
  # if(is.character(rObj) & length(rObj) == 1) {return(rObj)} # deal with edge case
  python.assign('tmp_var', rObj)
  python.exec(sprintf('
    with open("tmp_var.txt", "w") as f:
      f.write(json.dumps(%s))
      f.close()', 'tmp_var'))
  pyObjStr <- suppressWarnings(readLines('tmp_var.txt'))
  unlink('tmp_var.txt')
  return(pyObjStr)
}

# for annonymous args
# insertPyObjsStr(3, c(1,2,3))  => "3, [1, 2, 3]"
insertPyObjsStr <- function(...){
  args <- list(...)
  paste(unlist(lapply(args, function(arg){
    toPyObjStr(arg)
  })), collapse = ", ")
}

# createFuncStr('f', 3, c(1,2,3))  => "f(3, [1, 2, 3])"
createFuncStr <- function(funcName, ...){
  paste0(funcName, sprintf('(%s)', insertPyObjsStr(...)))
}

# for named arguments
additionalArgs <- function(theDots){
  paste0(ifelse(length(theDots) != 0, ", ", ""),
         createArgs(theDots, getFunc = get))
}

# funcWriter(ConvModel(), funcHeader = def conv_model(X, y):)
funcWriter <- function(body, funcHeader= 'def f():', returnValue = NULL){
  cat(paste0(funcHeader, "\n"))
  body
  cat(paste0("\t", returnValue, "\n"))
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
  X_df = DataFrame(X)
  X_lists = X_df.values.tolist()
  f = open("X_lists.txt", "w")
  f.write(json.dumps(X_lists))
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
  f = open("y_lists.txt", "w")
  f.write(json.dumps(y))
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

predict <- function(){
  cat("predictions = model.predict(X_test)\n")
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


