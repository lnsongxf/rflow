require(rPython)

importDeps <- function(){
cat("
from pandas import DataFrame
import os
import random
from sklearn import metrics
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

skflow.TensorFlowDNNClassifier <- function(hidden_units, n_classes, ...){
  theDots <- list(...)
  cat(paste0("classifier = skflow.TensorFlowDNNClassifier(",
         createArgs(c("hidden_units", "n_classes")), 
         ifelse(length(theDots) != 0, ", ", ""),
         createArgs(theDots),
         ")\n"))
}

classifier.predict <- function(){
  cat("classifier.predict(X)\n")
}
classifier.fit <- function(){
  cat("classifier.fit(X, y)\n")
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
  python.assign("y", as.integer(as.factor(iris[,5]))-1) # starts from 0
  python.exec('
  from numpy import asarray
  f = open("y_lists.txt", "w")
  f.write(json.dumps(y))
  f.close()')
  y_lists <- readLines("y_lists.txt")
  
  dtype <<- 'int64'
  
  cat(paste0("y = asarray(",
         y_lists, ", ",
         createArgs('dtype'),
         ")\n"))
  
  unlink("y_lists.txt")
}

# system(paste0("python TensorFlowDNNClassifier.py ",
#               paste0('"', X_lists, '"'),
#               " ", 
#               paste0('"', y_lists, '"')))


