# Deep Neural Network in R

## example of using DNN classifier
# configs for DNN classifier
predictors <- iris[1:4]
target <- iris[,5]
test_percent <- 0.25
hidden_units <- c(10, 20, 10)
n_classes <- length(unique(target))
steps <- 400

rflowPipeline(accuracyScore(),
              test_percent = test_percent,
              TensorFlowDNNClassifier(hidden_units = hidden_units,
                                      n_classes = n_classes,
                                      steps=steps),
              preparePredictors(predictors),
              prepareTargetVar(target))


## example of using DNN regressor
library(MASS)
data(Boston)
# configs for DNN regressor
predictors <- Boston[,2:14]
target <- Boston[,1]
test_percent <- 0.25
hidden_units <- c(10, 20, 10)
n_classes <- 0
steps <- 400

rflowPipeline(meanSquaredError(),
              test_percent = test_percent,
              TensorFlowDNNRegressor(hidden_units = hidden_units),
              preparePredictors(predictors),
              prepareTargetVar(target))
