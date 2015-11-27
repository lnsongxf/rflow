source('rflow_experiment.R')
# Deep Neural Network in R

## example of using DNN classifier
# configs for DNN classifier
predictors <- iris[1:4]
target <- iris[,5]
test_percent <- 0.25
hidden_units <- c(10, 20, 10)
n_classes <- length(unique(target))
steps <- 400

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


## example of using DNN regressor
# library(MASS)
data(Boston)
# configs for DNN regressor
predictors <- Boston[,2:14]
target <- Boston[,1]
test_percent <- 0.25
hidden_units <- c(10, 20, 10)
n_classes <- 0
steps <- 400

sink("test.py")
importDeps()
TensorFlowDNNRegressor(hidden_units = hidden_units)
preparePredictors(predictors)
prepareTargetVar(target)
trainTestSplit(test_percent)
fit()
predict()
meanSquaredError()
sink()

system("python test.py")
