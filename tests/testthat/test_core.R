context('Testing core functions')

# TODO: Validation check

importDeps()

importConstants()

predictors <<- iris[1:4]
target <<- iris[,5]
hidden_units <<- c(10, 20, 10)
n_classes <<- length(unique(target))
steps <<- 400
batch_size <<- 120
learning_rate <<- .05


preparePredictors(predictors)

prepareTargetVar(target)

TensorFlowDNNClassifier(hidden_units = hidden_units,
                        n_classes = n_classes,
                        steps=steps)

TensorFlowEstimator(n_classes = n_classes,
                    steps=steps,
                    learning_rate = learning_rate,
                    batch_size = batch_size)

TensorFlowDNNRegressor(hidden_units = hidden_units)

ConvModel()

loadMINST()

trainTestSplit()

fit()

predict()
