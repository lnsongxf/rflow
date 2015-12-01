# Customized DNN model in R

predictors <- iris[1:4]
target <- iris[,5]
n_classes <- length(unique(target))

rflowPipeline(eval_metric = 'accuracy_score',
              test_percent = 0.25,
              # write a custom model that will be passed to TensorFlowEstimator
              # a DNN model with hidden layers of 12, 18, 12 and 0.45 probability of dropout
              # using logistic regression as the activation function
              # check out helpers in customize_model_helpers.R
              customModelWriter(
                funcInput = c('X', 'y'),
                returnValue = TensorActivator('logistic_regression'),
                # you can append as many transformations as you like
                TensorOperator('dnn', c(12, 18, 12), keep_prob=0.45)),
              TensorFlowEstimator(n_classes = n_classes),
              preparePredictors(predictors),
              prepareTargetVar(target))
