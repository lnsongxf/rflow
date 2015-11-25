require(rPython)

data(iris)

hidden_units <- c(10, 20, 10)
n_classes <- 3
steps <- 200

importDeps <- function(){
cat("
import pandas as pd
import os
import random
from sklearn import metrics
import skflow
import numpy as np
import sys
")
}

createArgs <- function(names){
  if(length(names) == 0) return(NULL)
  if(is.list(names)){names <- names(names)} # deal with additional arguments
  cat(paste(unlist(lapply(names, function(name){
    RHS <- capture.output(dput(get(name)))
    paste0(name, "=", RHS)
  })), collapse = ", "))
}

# TODO: pasted string order is incorrect
skflow.TensorFlowDNNClassifier <- function(hidden_units, n_classes, ...){
  theDots <- list(...)
  cat(paste0("classifier = skflow.TensorFlowDNNClassifier(",
         createArgs(c("hidden_units", "n_classes")), ", ",
         createArgs(theDots),
         ")"))
}

classifier.predict <- function(X){
  "classifier.predict(X)"
}

preparePredictors <- function(predictors, dtype = 'float64'){
  python.assign("X", predictors)
  python.exec('
  X_df = pd.DataFrame(X)
  X_lists = X_df.values.tolist()
  f = open("X_lists.txt", "w")
  f.write(json.dumps(X_lists))
  f.close()')
  X_lists <- readLines("X_lists.txt")
  
  paste0("X = np.asarray(",
         X_lists, ", ",
         createArgs('dtype'),
         ")")
  
  unlink("X_lists.txt")
}

prepareTargetVar <- function(target, dtype = 'int64'){
  python.assign("y", as.integer(as.factor(iris[,5]))-1) # starts from 0
  python.exec('
  f = open("y_lists.txt", "w")
  f.write(json.dumps(y))
  f.close()')
  y_lists <- readLines("y_lists.txt")
  
  paste0("y = np.asarray(",
         y_lists, ", ",
         createArgs('dtype'),
         ")")
  
  unlink("y_lists.txt")
}

preparePredictors(iris[1:4])

cat(prepareTargetVar(iris[,5]))

system(paste0("python TensorFlowDNNClassifier.py ",
              paste0('"', X_lists, '"'),
              " ", 
              paste0('"', y_lists, '"')))

sink("test.py")
importDeps()
skflow.TensorFlowDNNClassifier(hidden_units = hidden_units, n_classes = n_classes)
sink()
