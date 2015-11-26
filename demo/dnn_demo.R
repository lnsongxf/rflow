source('rflow_experiment.R')
# Deep Neural Network on iris data in R

# TODO: Use pipeR
data(iris)
library(pipeR)

predictors <- iris[1:4]
target <- iris[,5]
test_percent <- 0.25
hidden_units <- c(10, 20, 10)
n_classes <- 3
steps <- 200

sink("test.py")
importDeps()
TensorFlowDNNClassifier(hidden_units = hidden_units, n_classes = n_classes)
preparePredictors(predictors)
prepareTargetVar(target)
trainTestSplit(test_percent)
fit()
predict()
accuracyScore()
sink()

system("python test.py")
