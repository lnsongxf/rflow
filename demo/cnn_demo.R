# Convolutional Neural Network in R

test_percent <- 0.25
n_classes <- 10
steps <- 400
learning_rate <- .045
batch_size <- 120

rflowPipeline(accuracyScore(),
              test_percent = test_percent,
              loadMINST(),
              ConvModel(),
              TensorFlowEstimator(n_classes = n_classes,
                                  steps=steps,
                                  learning_rate = learning_rate,
                                  batch_size = batch_size)
)
