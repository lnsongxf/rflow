require(rPython)

data(iris)

# hidden_units <- c(10, 20, 10)
# n_classes <- 3
# steps <- 200

importDeps <- function(){
"
import pandas as pd
import os
import random
from sklearn import metrics
import skflow
import numpy as np
import sys
"
}

createArgs <- function(names){
  paste(unlist(lapply(names, function(name){
    paste0(name, "=", capture.output(dput(get(name))))
  })), collapse = ", ")
}

skflow.TensorFlowDNNClassifier <- function(hidden_units, n_classes, tf_master="",
                                           batch_size=32, steps=50, optimizer="SGD",
                                           learning_rate=0.1, tf_random_seed=42){
  paste0("classifier = skflow.TensorFlowDNNClassifier(",
         createArgs(c("hidden_units", "n_classes", "tf_master", 
                      "batch_size", "steps", "optimizer",
                      "learning_rate", "tf_random_seed")),
         ")")
}

classifier.predict <- function(X){
  "classifier.predict(X)"
}

preparePredictors <- function(predictors){
  python.assign("X", predictors)
  python.exec('
  X_df = pd.DataFrame(X)
  X_lists = X_df.values.tolist()
  f = open("X_lists.txt", "w")
  f.write(json.dumps(X_lists))
  f.close()')
}

prepareTargetVar <- function(target){
  python.assign("y", as.integer(as.factor(iris[,5]))-1) # starts from 0
  python.exec('
  f = open("y_lists.txt", "w")
  f.write(json.dumps(y))
  f.close()')
}

preparePredictors(iris[1:4])
X_lists <- readLines("X_lists.txt")
unlink("X_lists.txt")

prepareTargetVar(iris[,5])
y_lists <- readLines("y_lists.txt")
unlink("y_lists.txt")

system(paste0("python TensorFlowDNNClassifier.py ",
              paste0('"', X_lists, '"'),
              " ", 
              paste0('"', y_lists, '"')))

