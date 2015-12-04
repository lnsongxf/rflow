# context('Testing rflowPipeline')
# 
# # DNN classifier use pipeline
# predictors <<- iris[1:4]
# target <<- iris[,5]
# hidden_units <<- c(10, 20, 10)
# n_classes <<- length(unique(target))
# steps <<- 400
# 
# rflowPipeline(eval_metric = 'accuracy_score',
#               test_percent = 0.25,
#               TensorFlowDNNClassifier(hidden_units = hidden_units,
#                                       n_classes = n_classes,
#                                       steps=steps),
#               preparePredictors(predictors),
#               prepareTargetVar(target))
# 
# # CNN classifier using pipeline
# n_classes <<- 10
# steps <<- 400
# learning_rate <<- .045
# batch_size <<- 120
# 
# rflowPipeline(eval_metric = 'accuracy_score',
#               test_percent = 0.25,
#               loadMINST(),
#               ConvModel(),
#               TensorFlowEstimator(n_classes = n_classes,
#                                   steps=steps,
#                                   learning_rate = learning_rate,
#                                   batch_size = batch_size)
# )
