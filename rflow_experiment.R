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
")
}

createArgs <- function(names){
  if(length(names) == 0) return(NULL)
  if(is.list(names)){names <- names(names)} # deal with additional arguments
  paste(unlist(lapply(names, function(name){
    python.assign(name, get(name))
    python.exec(sprintf('
    f = open("tmp_var.txt", "w")
    f.write(json.dumps(%s))
    f.close()', name))
    RHS <- readLines('tmp_var.txt')
    unlink('tmp_var.txt')
    # RHS <- capture.output(dput(get(name)))
    paste0(name, "=", RHS)
  })), collapse = ", ")
}

TensorFlowDNNClassifier <- function(hidden_units, n_classes, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowDNNClassifier(",
         createArgs(c("hidden_units", "n_classes")), 
         ifelse(length(theDots) != 0, ", ", ""),
         createArgs(theDots),
         ")\n"))
}

TensorFlowDNNRegressor <- function(hidden_units, ...){
  theDots <- list(...)
  cat(paste0("model = skflow.TensorFlowDNNRegressor(",
             createArgs(c("hidden_units")), 
             ifelse(length(theDots) != 0, ", ", ""),
             createArgs(theDots),
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
  X_lists <- readLines("X_lists.txt")
  
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
  y_lists <- readLines("y_lists.txt")
  
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

